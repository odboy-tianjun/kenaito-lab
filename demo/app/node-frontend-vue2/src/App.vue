<template>
  <div class="app">
    <el-container>
      <el-header height="56px" class="header">
        <span class="logo">node-frontend-vue2</span>
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
  </div>
</template>

<script>
export default {
  name: 'App',
};
</script>
