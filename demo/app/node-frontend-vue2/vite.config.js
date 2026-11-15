import { defineConfig } from 'vite';
import vue2 from '@vitejs/plugin-vue2';

// 纯静态前端：产物由 Tengine 托管，base 用相对路径，部署到任意子路径都能跑
export default defineConfig({
  plugins: [vue2()],
  base: './',
  server: {
    host: '0.0.0.0',
    port: 5173,
  },
  build: {
    outDir: 'dist',
    // 不生成 sourcemap，减小部署体积；需要排查时改成 true
    sourcemap: false,
    // element-ui 体积较大，单独拆包，利用浏览器缓存
    rollupOptions: {
      output: {
        manualChunks: {
          'element-ui': ['element-ui'],
          vue: ['vue', 'vue-router'],
        },
      },
    },
  },
});
