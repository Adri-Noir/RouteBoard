import { defineConfig, defaultPlugins } from "@hey-api/openapi-ts";

export default defineConfig({
  input: "openapi.json",
  output: {
    path: "src/lib/api",
    format: "prettier",
  },
  plugins: [...defaultPlugins, "@hey-api/client-fetch", "@tanstack/react-query"],
});
