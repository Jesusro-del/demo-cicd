// Resumen de un job para la página del run (GITHUB_STEP_SUMMARY): quien aprueba STAGING
// tiene que saber qué está aprobando sin abrir ningún log.
// Uso:
//   node scripts/resumen.mjs pruebas <vitest.json> "<título>"
//   node scripts/resumen.mjs trivy <trivy.json> "<imagen>"
//   node scripts/resumen.mjs grype <grype.json> "<imagen>"
// Si el JSON no existe (el paso anterior ni llegó a correr), lo dice en vez de fallar:
// el job ya está en rojo por su propio paso, el resumen solo informa.
import { appendFileSync, existsSync, readFileSync } from "node:fs";

const [tipo, archivo, titulo] = process.argv.slice(2);

function escribir(md) {
  if (process.env.GITHUB_STEP_SUMMARY) appendFileSync(process.env.GITHUB_STEP_SUMMARY, md + "\n");
  console.log(md);
}

if (!archivo || !existsSync(archivo)) {
  escribir(`### ${titulo}\n\n⚠️ No hay resultados: el paso anterior no llegó a generarlos. Mira el log del job.\n`);
  process.exit(0);
}
const datos = JSON.parse(readFileSync(archivo, "utf-8"));

// En una tabla de Markdown, un "|" dentro del texto rompería la columna.
const celda = (texto) => String(texto ?? "").replaceAll("|", "\\|").replaceAll("\n", " ");

if (tipo === "pruebas") {
  const fallidas = datos.testResults.flatMap((r) => r.assertionResults.filter((a) => a.status === "failed"));
  const icono = datos.numFailedTests === 0 ? "✅" : "❌";
  let md = `### ${icono} ${titulo}\n\n`;
  md += "| Total | Pasaron | Fallaron | Omitidas |\n|:-:|:-:|:-:|:-:|\n";
  md += `| ${datos.numTotalTests} | ${datos.numPassedTests} | ${datos.numFailedTests} | ${datos.numPendingTests + datos.numTodoTests} |\n`;
  if (fallidas.length) {
    md += "\n**Fallaron:**\n\n";
    for (const f of fallidas) md += `- ${celda(f.fullName)}: \`${celda(f.failureMessages[0]?.split("\n")[0])}\`\n`;
  }
  escribir(md);
} else if (tipo === "trivy") {
  const vulns = (datos.Results ?? []).flatMap((r) => (r.Vulnerabilities ?? []).map((v) => ({ ...v, Target: r.Target })));
  const cuenta = (sev) => vulns.filter((v) => v.Severity === sev).length;
  const icono = vulns.length === 0 ? "✅" : "❌";
  let md = `### ${icono} Trivy: ${titulo}\n\n`;
  md += "Severidades que frenan el pipeline, con parche disponible y sin contar las aceptadas en `.trivyignore`.\n\n";
  md += "| CRITICAL | HIGH |\n|:-:|:-:|\n";
  md += `| ${cuenta("CRITICAL")} | ${cuenta("HIGH")} |\n`;
  if (vulns.length) {
    md += "\n| Severidad | CVE | Paquete | Instalada | Corregida en |\n|---|---|---|---|---|\n";
    for (const v of vulns) {
      md += `| ${v.Severity} | ${celda(v.VulnerabilityID)} | ${celda(v.PkgName)} | ${celda(v.InstalledVersion)} | ${celda(v.FixedVersion)} |\n`;
    }
  }
  escribir(md);
} else if (tipo === "grype") {
  // Con --only-fixed, matches trae solo lo que tiene parche. ignoredMatches mezcla dos cosas: lo que descarta
  // --only-fixed (regla con fix-state) y lo aceptado en .grype.yaml (regla con vulnerability). Se separan.
  // Grype escribe la severidad con mayúscula inicial ("High").
  const ignoradas = datos.ignoredMatches ?? [];
  const porRegla = (campo) => ignoradas.filter((m) => (m.appliedIgnoreRules ?? []).some((r) => r[campo]));
  const aceptadas = porRegla("vulnerability");
  const sinParche = ignoradas.filter((m) => !aceptadas.includes(m));
  const vulns = (datos.matches ?? []).map((m) => ({
    sev: m.vulnerability.severity, id: m.vulnerability.id,
    pkg: m.artifact.name, version: m.artifact.version, fix: (m.vulnerability.fix?.versions ?? []).join(", "),
  }));
  const frenan = vulns.filter((v) => v.sev === "Critical" || v.sev === "High");
  const cuenta = (sev) => vulns.filter((v) => v.sev === sev).length;
  const icono = frenan.length === 0 ? "✅" : "❌";
  let md = `### ${icono} Grype: ${titulo}\n\n`;
  md += "Por severidad, las que tienen parche: frenan `Critical` y `High`. Aparte, las que no tienen parche (no frenan) y las aceptadas en `.grype.yaml`.\n\n";
  md += "| Critical | High | Medium | Low | Sin parche | Aceptadas |\n|:-:|:-:|:-:|:-:|:-:|:-:|\n";
  md += `| ${cuenta("Critical")} | ${cuenta("High")} | ${cuenta("Medium")} | ${cuenta("Low")} | ${sinParche.length} | ${aceptadas.length} |\n`;
  if (frenan.length) {
    md += "\n| Severidad | Vulnerabilidad | Paquete | Instalada | Corregida en |\n|---|---|---|---|---|\n";
    for (const v of frenan) md += `| ${v.sev} | ${celda(v.id)} | ${celda(v.pkg)} | ${celda(v.version)} | ${celda(v.fix)} |\n`;
  }
  // El detalle completo, plegado: lo que no frena también se ve, para que nada quede escondido.
  const lista = (titulo, ms) => {
    if (!ms.length) return "";
    const items = ms.map((m) => `${m.vulnerability.id} (${m.vulnerability.severity}, ${m.artifact.name} ${m.artifact.version})`);
    return `\n<details><summary>${titulo} (${ms.length})</summary>\n\n${celda(items.join(", "))}\n\n</details>\n`;
  };
  md += lista("Con parche que no frenan (Medium, Low)", (datos.matches ?? []).filter((m) => !["Critical", "High"].includes(m.vulnerability.severity)));
  md += lista("Sin parche", sinParche);
  md += lista("Aceptadas en .grype.yaml", aceptadas);
  escribir(md);
} else {
  console.error(`Tipo desconocido: ${tipo}. Usa "pruebas", "trivy" o "grype".`);
  process.exit(2);
}
