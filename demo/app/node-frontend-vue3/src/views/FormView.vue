<template>
  <el-card shadow="never">
    <template #header><span>Element Plus 表单</span></template>
    <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
      <el-form-item label="名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入名称" />
      </el-form-item>
      <el-form-item label="类型" prop="type">
        <el-select v-model="form.type" placeholder="请选择">
          <el-option label="前端" value="frontend" />
          <el-option label="后端" value="backend" />
        </el-select>
      </el-form-item>
      <el-form-item label="启用">
        <el-switch v-model="form.enabled" />
      </el-form-item>
      <el-form-item label="日期">
        <el-date-picker v-model="form.date" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submit">提交</el-button>
        <el-button @click="reset">重置</el-button>
      </el-form-item>
    </el-form>
    <el-alert v-if="result" :title="result" type="success" :closable="false" show-icon />
  </el-card>
</template>

<script setup>
import { reactive, ref } from 'vue';
import { ElMessage } from 'element-plus';

const emptyForm = () => ({ name: '', type: '', enabled: true, date: '' });

const formRef = ref(null);
const form = reactive(emptyForm());
const result = ref('');
const rules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择类型', trigger: 'change' }],
};

function submit() {
  formRef.value.validate((ok) => {
    if (!ok) return;
    result.value = `已提交：${JSON.stringify(form)}`;
    ElMessage.success('提交成功');
  });
}

function reset() {
  formRef.value.resetFields();
  result.value = '';
}
</script>
