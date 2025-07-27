import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,     // Change default port from 5173 to 3000
    host: true      // Allow access from Docker container or network
  }
})
