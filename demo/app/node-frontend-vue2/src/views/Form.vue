<template>
  <el-card shadow="never">
    <div slot="header"><span>Element UI 2 常用组件</span></div>
    <el-form ref="form" :model="form" :rules="rules" label-width="100px">
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
        <el-date-picker v-model="form.date" type="date" value-format="yyyy-MM-dd" placeholder="选择日期" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submit">提交</el-button>
        <el-button @click="reset">重置</el-button>
      </el-form-item>
    </el-form>
    <el-alert v-if="result" :title="result" type="success" :closable="false" show-icon />
  </el-card>
</template>

<script>
const emptyForm = () => ({ name: '', type: '', enabled: true, date: '' });

export default {
  name: 'Form',
  data() {
    return {
      form: emptyForm(),
      result: '',
      rules: {
        name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
        type: [{ required: true, message: '请选择类型', trigger: 'change' }],
      },
    };
  },
  methods: {
    submit() {
      this.$refs.form.validate((ok) => {
        if (!ok) return;
        this.result = `已提交：${JSON.stringify(this.form)}`;
        this.$message.success('提交成功');
      });
    },
    reset() {
      this.$refs.form.resetFields();
      this.result = '';
    },
  },
};
</script>
