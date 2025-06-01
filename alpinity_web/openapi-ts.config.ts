import { defaultPlugins, defineConfig } from "@hey-api/openapi-ts";

export default defineConfig({
  input: "openapi.json",
  output: {
    path: "src/lib/api",
    format: "prettier",
  },
  plugins: [
    ...defaultPlugins,
    {
      name: "@hey-api/client-fetch",
      runtimeConfigPath: "./src/lib/hey-api.ts",
    },
    "@tanstack/react-query",
  ],
});
