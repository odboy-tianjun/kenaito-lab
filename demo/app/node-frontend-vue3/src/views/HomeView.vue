<template>
  <div>
    <el-row :gutter="16">
      <el-col :span="8">
        <el-card shadow="never">
          <template #header><span>运行时</span></template>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="Vue">{{ vueVersion }}</el-descriptions-item>
            <el-descriptions-item label="Element Plus">2.14.8</el-descriptions-item>
            <el-descriptions-item label="路由">createWebHashHistory</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never">
          <template #header><span>计数器（ref）</span></template>
          <el-statistic :value="count" title="当前值" />
          <div style="margin-top: 16px">
            <el-button size="small" @click="count -= 1">-1</el-button>
            <el-button size="small" type="primary" @click="count += 1">+1</el-button>
            <el-button size="small" @click="count = 0">重置</el-button>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never">
          <template #header><span>当前时间</span></template>
          <p class="clock">{{ clock }}</p>
          <el-tag type="success" size="small">前端本地时间，不请求后端</el-tag>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" style="margin-top: 16px">
      <template #header><span>Element Plus 组件一览</span></template>
      <el-space wrap>
        <el-button>默认</el-button>
        <el-button type="primary">主要</el-button>
        <el-button type="success">成功</el-button>
        <el-tag>标签</el-tag>
        <el-tag type="info" effect="plain">描边</el-tag>
        <el-switch v-model="enabled" />
        <el-rate v-model="rate" />
        <el-progress :percentage="percent" style="width: 200px" />
      </el-space>
      <el-divider />
      <el-input v-model="keyword" placeholder="输入关键字过滤，纯前端" clearable style="max-width: 320px" />
      <el-alert
        v-if="keyword"
        style="margin-top: 12px"
        :title="`已输入：${keyword}`"
        type="info"
        :closable="false"
        show-icon
      />
    </el-card>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref, version as vueVersionValue } from 'vue';

// 纯前端展示：所有数据都在浏览器里产生，不调用任何后端接口
const vueVersion = vueVersionValue;
const count = ref(0);
const clock = ref(format(new Date()));
const enabled = ref(true);
const rate = ref(4);
const percent = ref(60);
const keyword = ref('');
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

<style scoped>
.clock {
  margin: 0 0 12px;
  font-size: 24px;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}
</style>
