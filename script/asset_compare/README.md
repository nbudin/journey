# Asset pipeline equivalence checks

Tools for verifying that a change to the asset pipeline (Sprockets, Sass compiler, JS bundling) did not change what
users get. Byte-identical output is not required; these check that the output is *equivalent*.

Needs Node. Install once: `cd script/asset_compare && npm install`.

## 1. Compiled files: `compare.js`

```sh
# build the reference on the old code, then the candidate on the new code
RAILS_ENV=production SECRET_KEY_BASE=x DATABASE_URL=postgres:///some_migrated_db bin/rails assets:precompile
cp -R public/assets /tmp/assets_ref        # (and again for /tmp/assets_new after switching branches)

node script/asset_compare/compare.js /tmp/assets_ref /tmp/assets_new     # SHOW_DIFF=1 prints first difference
```

Matches files by name with the digest stripped, then compares CSS (csso-normalised) and JS (esbuild-minified).
Exit code 0 means equivalent. Reformatting, comment changes, `#ffffff` vs `#fff` etc. are accepted; any change to a
rule, value or statement is reported.

## 2. Rendering: `render_snapshot_test.rb` + `diff_snap.js`

Loads 23 pages (editor, survey flow, response viewer, graphs, publish pages...) in headless Chrome against a fixed,
deterministic questionnaire and records every element's computed style, geometry and a screenshot.

```sh
SNAPSHOT_OUT=/tmp/snap_ref bin/rails test script/asset_compare/render_snapshot_test.rb   # on the old code
SNAPSHOT_OUT=/tmp/snap_new bin/rails test script/asset_compare/render_snapshot_test.rb   # on the new code
node script/asset_compare/diff_snap.js /tmp/snap_ref /tmp/snap_new
```

Run it twice on the same code first: the result should be "ALL 23 PAGES IDENTICAL" (it is deterministic; ids are reset
per run and the random server port is normalised). Output also depends on the Chrome version, so compare snapshots
taken on the same machine.

It runs the test environment's asset pipeline (live compilation), so it complements `compare.js`, which looks at the
precompiled production files. JS behaviour (editor, sorting, survey flow) is covered by the normal browser tests.

## 3. TinyMCE against the precompiled production assets: `editor_check.rb`

Neither the test suite nor the snapshot test serves `public/assets`, and TinyMCE loads its theme, skin and plugins at
runtime from non-digested paths under `/assets/tinymce/`, so a pipeline change can break the editor without any test
noticing. This boots the app in production mode against a scratch database, serves the precompiled assets, logs in,
opens the two pages with an HTML editor, and checks that TinyMCE initialises, accepts content and applies Bold.

```sh
export RAILS_ENV=production SECRET_KEY_BASE=x DATABASE_URL=postgres:///some_migrated_empty_scratch_db
bin/rails assets:precompile
bundle exec ruby script/asset_compare/editor_check.rb     # from the repo root; exits non-zero on failure
```

It also prints the browser's failed requests as `note` lines. Run it on the old and new pipeline and diff the output:
some notes are already present (404s for `questionnaire.css` and the TinyMCE icon fonts `/fonts/tinymce.*`).
