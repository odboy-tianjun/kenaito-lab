<template>
  <el-container class="app">
    <el-header height="56px" class="header">
      <span class="logo">node-frontend-vue3</span>
      <el-menu mode="horizontal" :default-active="$route.path" router :ellipsis="false">
        <el-menu-item index="/">首页</el-menu-item>
        <el-menu-item index="/form">表单</el-menu-item>
        <el-menu-item index="/about">关于</el-menu-item>
      </el-menu>
    </el-header>
    <el-main>
      <router-view />
    </el-main>
  </el-container>
</template>

<script setup>
// Vue 3 单文件组件 + 组合式 API，脚本部分刻意保持最小
</script>
