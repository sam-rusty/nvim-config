-- LazyVim's rust extra already sets `cargo.allFeatures = true`, so this is not a
-- feature-flag problem. Endpoint macros (`#[get]`, `#[post]`, ...) expand into
-- mutually exclusive `#[cfg]` branches (native vs. Worker, server vs. client). At
-- least one branch is always off, and rust-analyzer reports it on the attribute.
return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            diagnostics = {
              disabled = { "inactive_code" },
            },
          },
        },
      },
    },
  },
}
