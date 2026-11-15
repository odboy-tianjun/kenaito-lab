<template>
  <el-card shadow="never">
    <template #header><span>关于</span></template>
    <el-descriptions :column="1" border>
      <el-descriptions-item label="框架">Vue 3.5.45（组合式 API，&lt;script setup&gt;）</el-descriptions-item>
      <el-descriptions-item label="组件库">Element Plus 2.14.8</el-descriptions-item>
      <el-descriptions-item label="构建">Vite 7 + @vitejs/plugin-vue 6</el-descriptions-item>
      <el-descriptions-item label="部署">Tengine 3.1.0（proxy-tengine3 镜像）托管 dist/</el-descriptions-item>
      <el-descriptions-item label="路由模式">hash（无需服务端 rewrite）</el-descriptions-item>
    </el-descriptions>
  </el-card>
</template>

<script setup>
// 静态说明页，无逻辑
</script>
