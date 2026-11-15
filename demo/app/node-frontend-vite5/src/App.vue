<template>
  <div class="app">
    <header class="header">
      <span class="logo">node-frontend-vite5</span>
      <span class="tag">Vite 5 + Vue 3</span>
    </header>
    <main class="main">
      <div class="grid">
        <section class="card">
          <h3 class="card-title">构建信息</h3>
          <table class="kv">
            <tbody>
              <tr><th>Vite</th><td>{{ viteVersion }}</td></tr>
              <tr><th>Vue</th><td>{{ vueVersion }}</td></tr>
              <tr><th>Node 要求</th><td>Vite 5 支持 Node 18+（镜像用 22）</td></tr>
            </tbody>
          </table>
        </section>

        <section class="card">
          <h3 class="card-title">计数器</h3>
          <p class="big">{{ count }}</p>
          <button class="btn" @click="count -= 1">-1</button>
          <button class="btn primary" @click="count += 1">+1</button>
          <button class="btn" @click="count = 0">重置</button>
        </section>

        <section class="card">
          <h3 class="card-title">当前时间</h3>
          <p class="big small">{{ clock }}</p>
          <span class="hint">前端本地时间，不请求后端</span>
        </section>
      </div>

      <section class="card">
        <h3 class="card-title">构建环境变量（import.meta.env）</h3>
        <table class="kv">
          <tbody>
            <tr><th>MODE</th><td>{{ env.MODE }}</td></tr>
            <tr><th>PROD</th><td>{{ env.PROD }}</td></tr>
            <tr><th>BASE_URL</th><td>{{ env.BASE_URL }}</td></tr>
          </tbody>
        </table>
      </section>
    </main>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue';
import { version as vueVersionValue } from 'vue';

// Vite 在构建时把 import.meta.env 静态替换成字面量，生产包里不会泄露其它环境变量
const env = import.meta.env;
const viteVersion = `5.4.21`;
const vueVersion = vueVersionValue;

const count = ref(0);
const clock = ref(format(new Date()));
let timer = null;

function format(d) {
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`;
}

onMounted(() => {
  timer = setInterval(() => {
    clock.value = format(new Date());
  }, 1000);
});

onBeforeUnmount(() => clearInterval(timer));
</script>
