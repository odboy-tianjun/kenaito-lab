import { useState } from 'react';

const EMPTY = { name: '', type: '', enabled: true, date: '' };

// 受控表单 + 简单校验，不引入表单库
export default function Form() {
  const [form, setForm] = useState(EMPTY);
  const [errors, setErrors] = useState({});
  const [result, setResult] = useState('');

  const update = (key, value) => setForm((prev) => ({ ...prev, [key]: value }));

  const validate = () => {
    const next = {};
    if (!form.name.trim()) next.name = '请输入名称';
    if (!form.type) next.type = '请选择类型';
    setErrors(next);
    return Object.keys(next).length === 0;
  };

  const submit = (e) => {
    e.preventDefault();
    if (!validate()) return;
    setResult(`已提交：${JSON.stringify(form)}`);
  };

  const reset = () => {
    setForm(EMPTY);
    setErrors({});
    setResult('');
  };

  return (
    <div className="card">
      <h3 className="card-title">React 受控表单</h3>
      <form onSubmit={submit} noValidate>
        <div className="field">
          <label htmlFor="name">名称</label>
          <input id="name" value={form.name} onChange={(e) => update('name', e.target.value)} placeholder="请输入名称" />
          {errors.name && <span className="error">{errors.name}</span>}
        </div>
        <div className="field">
          <label htmlFor="type">类型</label>
          <select id="type" value={form.type} onChange={(e) => update('type', e.target.value)}>
            <option value="">请选择</option>
            <option value="frontend">前端</option>
            <option value="backend">后端</option>
          </select>
          {errors.type && <span className="error">{errors.type}</span>}
        </div>
        <div className="field">
          <label htmlFor="enabled">启用</label>
          <input id="enabled" type="checkbox" checked={form.enabled} onChange={(e) => update('enabled', e.target.checked)} />
        </div>
        <div className="field">
          <label htmlFor="date">日期</label>
          <input id="date" type="date" value={form.date} onChange={(e) => update('date', e.target.value)} />
        </div>
        <div className="field">
          <label />
          <button type="submit" className="btn primary">提交</button>{' '}
          <button type="button" className="btn" onClick={reset}>重置</button>
        </div>
      </form>
      {result && <div className="hint">{result}</div>}
    </div>
  );
}
