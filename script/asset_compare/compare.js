// Compare two precompiled Sprockets asset directories for equivalence (not byte identity).
//   node compare.js <refDir> <newDir>
// Exit code 0 if equivalent, 1 otherwise.
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const csso = require("csso");
const esbuild = require("esbuild");

const [refDir, newDir] = process.argv.slice(2);
if (!refDir || !newDir) { console.error("usage: compare.js refDir newDir"); process.exit(2); }

const DIGEST = /-[0-9a-f]{64}(?=\.[^.\/]+$)/;
const stripDigest = (p) => p.replace(DIGEST, "");

function walk(dir, base = dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walk(full, base, out);
    else if (!e.name.endsWith(".gz") && !e.name.startsWith(".sprockets-manifest")) out.push(path.relative(base, full));
  }
  return out;
}

function index(dir) {
  const m = new Map();
  for (const rel of walk(dir)) m.set(stripDigest(rel), rel);
  return m;
}

const sha = (buf) => crypto.createHash("sha256").update(buf).digest("hex");
const problems = [];
const note = (kind, name, detail = "") => problems.push(`${kind}: ${name} ${detail}`.trim());

// Canonical CSS: parse, drop comments, normalise values/colours/numbers, don't restructure rules.
function normCss(src) {
  return csso.minify(src, { restructure: false, comments: false }).css;
}
// Canonical JS: parse + minify with a fixed tool/config. Keeps names so diffs stay readable.
function normJs(src) {
  return esbuild.transformSync(src, { minify: true, minifyIdentifiers: false, legalComments: "none", target: "es2020" }).code;
}

const ref = index(refDir), now = index(newDir);
for (const k of ref.keys()) if (!now.has(k)) note("MISSING in new", k);
for (const k of now.keys()) if (!ref.has(k)) note("EXTRA in new", k);

const stats = { identical: 0, equivalent: 0, different: 0 };
for (const [k, relRef] of ref) {
  if (!now.has(k)) continue;
  const a = fs.readFileSync(path.join(refDir, relRef)), b = fs.readFileSync(path.join(newDir, now.get(k)));
  if (sha(a) === sha(b)) { stats.identical++; continue; }
  let na, nb;
  try {
    if (k.endsWith(".css")) { na = normCss(a.toString()); nb = normCss(b.toString()); }
    else if (k.endsWith(".js")) { na = normJs(a.toString()); nb = normJs(b.toString()); }
  } catch (e) { note("PARSE ERROR", k, e.message.split("\n")[0]); stats.different++; continue; }
  if (na !== undefined && na === nb) { stats.equivalent++; continue; }
  stats.different++;
  note("DIFFERENT", k, na === undefined ? "(binary/other, bytes differ)" : `(normalised ${na.length} vs ${nb.length} chars)`);
  if (na !== undefined && process.env.SHOW_DIFF) {
    let i = 0; while (i < na.length && na[i] === nb[i]) i++;
    console.log(`  first difference in ${k} at ${i}:\n    ref: ${JSON.stringify(na.slice(Math.max(0, i - 60), i + 80))}\n    new: ${JSON.stringify(nb.slice(Math.max(0, i - 60), i + 80))}`);
  }
}
console.log(`files: ref=${ref.size} new=${now.size}  byte-identical=${stats.identical} equivalent-after-normalising=${stats.equivalent} different=${stats.different}`);
if (problems.length) { console.log(problems.join("\n")); process.exit(1); }
console.log("EQUIVALENT");
