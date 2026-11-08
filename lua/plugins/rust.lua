-- LazyVim's rust extra already sets `cargo.allFeatures = true`, so this is not a
-- feature-flag problem. Endpoint macros (`#[get]`, `#[post]`, ...) expand into
-- mutually exclusive `#[cfg]` branches (native vs. Worker, server vs. client). At
-- least one branch is always off, and rust-analyzer reports it on the attribute.
--
-- targetDir gives rust-analyzer its own target/rust-analyzer, so its check-on-save never
-- waits on (or blocks) the cargo lock held by `dx serve`, `cargo build` or nextest.
return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      tools = {
        -- Failing tests from :RustLsp testables show up as diagnostics on the test.
        test_executor = "background",
      },
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            cargo = { targetDir = true },
            diagnostics = {
              disabled = { "inactive_code" },
            },
          },
        },
      },
    },
  },
}
