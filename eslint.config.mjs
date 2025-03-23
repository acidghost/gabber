import { defineConfig } from "eslint/config";
import globals from "globals";
import js from "@eslint/js";
import eslintConfigPrettier from "eslint-config-prettier";

export default defineConfig([
  {
    files: ["**/*.{js,msj,cjs"],
    plugins: { js },
    extends: ["js/recommended"],
  },
  {
    files: ["Extension/**/*.js"],
    plugins: { js },
    extends: ["js/recommended"],
    languageOptions: {
      sourceType: "script",
      globals: globals.browser,
    },
  },
  eslintConfigPrettier,
]);
