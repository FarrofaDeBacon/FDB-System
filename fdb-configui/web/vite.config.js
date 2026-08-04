import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte()],
  base: './', // CRÍTICO: Paths relativos para o CEF do FiveM/RedM
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  }
})
