// node diff_snap.js <refDir> <newDir>   -- compares computed styles, geometry and pixels of page snapshots
const fs = require("fs"), path = require("path");
const { PNG } = require("pngjs"); const pixelmatch = require("pixelmatch");
const [a, b] = process.argv.slice(2);
const names = fs.readdirSync(a).filter(f => f.endsWith(".json") && !f.startsWith("_")).map(f => f.replace(/\.json$/, ""));
let bad = 0;
for (const n of names) {
  const load = (d) => JSON.parse(fs.readFileSync(path.join(d, n + ".json"), "utf8").replace(/http:\/\/127\.0\.0\.1:\d+/g, "http://HOST"));
  const A = load(a), B = load(b);
  const issues = [];
  const ka = Object.keys(A.els), kb = new Set(Object.keys(B.els));
  const missing = ka.filter(k => !kb.has(k)), extra = [...kb].filter(k => !(k in A.els));
  if (missing.length || extra.length) issues.push(`DOM differs: ${missing.length} elements only in ref, ${extra.length} only in new (e.g. ${(missing[0]||extra[0]||"").slice(-70)})`);
  let styleDiffs = 0, rectDiffs = 0; const propCount = {}; let sample = null;
  for (const k of ka) {
    if (!kb.has(k)) continue;
    const sa = A.styles[A.els[k]], sb = B.styles[B.els[k]];
    if (A.els[k] !== undefined && JSON.stringify(sa) !== JSON.stringify(sb)) {
      styleDiffs++;
      for (const p of new Set([...Object.keys(sa), ...Object.keys(sb)])) if (sa[p] !== sb[p]) { propCount[p] = (propCount[p] || 0) + 1; sample = sample || `${k.slice(-60)} ${p}: ${sa[p]} -> ${sb[p]}`; }
    }
    if (JSON.stringify(A.rects[k]) !== JSON.stringify(B.rects[k])) rectDiffs++;
  }
  if (styleDiffs) issues.push(`computed style differs on ${styleDiffs} elements; props: ${Object.entries(propCount).sort((x,y)=>y[1]-x[1]).slice(0,6).map(e=>e.join("x")).join(", ")}; e.g. ${sample}`);
  if (rectDiffs) issues.push(`geometry differs on ${rectDiffs} elements`);
  const pa = path.join(a, n + ".png"), pb = path.join(b, n + ".png");
  if (fs.existsSync(pa) && fs.existsSync(pb)) {
    const ia = PNG.sync.read(fs.readFileSync(pa)), ib = PNG.sync.read(fs.readFileSync(pb));
    if (ia.width !== ib.width || ia.height !== ib.height) issues.push(`screenshot size ${ia.width}x${ia.height} vs ${ib.width}x${ib.height}`);
    else { const px = pixelmatch(ia.data, ib.data, null, ia.width, ia.height, { threshold: 0 }); if (px) issues.push(`screenshot differs in ${px} pixels`); }
  }
  console.log(`${issues.length ? "DIFF " : "same "} ${n} (${ka.length} elements)`);
  issues.forEach(i => console.log("      " + i));
  if (issues.length) bad++;
}
console.log(bad ? `\n${bad}/${names.length} pages differ` : `\nALL ${names.length} PAGES IDENTICAL (styles, geometry, pixels)`);
process.exit(bad ? 1 : 0);
