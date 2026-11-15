<template>
  <el-card shadow="never">
    <div slot="header"><span>关于</span></div>
    <el-descriptions :column="1" border>
      <el-descriptions-item label="框架">Vue 2.7.16（选项式 API）</el-descriptions-item>
      <el-descriptions-item label="组件库">Element UI 2.15.14</el-descriptions-item>
      <el-descriptions-item label="构建">Vite 7 + @vitejs/plugin-vue2</el-descriptions-item>
      <el-descriptions-item label="部署">Tengine 3.1.0（proxy-tengine3 镜像）托管 dist/</el-descriptions-item>
      <el-descriptions-item label="路由模式">hash（无需服务端 rewrite；换成 history 需要 try_files 兜底）</el-descriptions-item>
    </el-descriptions>
  </el-card>
</template>

<script>
export default {
  name: 'About',
};
</script>
