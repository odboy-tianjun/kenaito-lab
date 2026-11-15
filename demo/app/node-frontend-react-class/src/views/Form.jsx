import { Component } from 'react';

const EMPTY = { name: '', type: '', enabled: true, date: '' };

// 类组件受控表单：字段统一走 this.state.form，错误与结果各占一个 state 字段
export default class Form extends Component {
  constructor(props) {
    super(props);
    this.state = { form: { ...EMPTY }, errors: {}, result: '' };
    this.update = this.update.bind(this);
    this.submit = this.submit.bind(this);
    this.reset = this.reset.bind(this);
  }

  update(key, value) {
    this.setState((s) => ({ form: { ...s.form, [key]: value } }));
  }

  validate(form) {
    const next = {};
    if (!form.name.trim()) next.name = '请输入名称';
    if (!form.type) next.type = '请选择类型';
    this.setState({ errors: next });
    return Object.keys(next).length === 0;
  }

  submit(e) {
    e.preventDefault();
    const { form } = this.state;
    if (!this.validate(form)) return;
    this.setState({ result: `已提交：${JSON.stringify(form)}` });
  }

  reset() {
    this.setState({ form: { ...EMPTY }, errors: {}, result: '' });
  }

  render() {
    const { form, errors, result } = this.state;
    return (
      <div className="card">
        <h3 className="card-title">React 类组件受控表单</h3>
        <form onSubmit={this.submit} noValidate>
          <div className="field">
            <label htmlFor="name">名称</label>
            <input id="name" value={form.name} onChange={(e) => this.update('name', e.target.value)} placeholder="请输入名称" />
            {errors.name && <span className="error">{errors.name}</span>}
          </div>
          <div className="field">
            <label htmlFor="type">类型</label>
            <select id="type" value={form.type} onChange={(e) => this.update('type', e.target.value)}>
              <option value="">请选择</option>
              <option value="frontend">前端</option>
              <option value="backend">后端</option>
            </select>
            {errors.type && <span className="error">{errors.type}</span>}
          </div>
          <div className="field">
            <label htmlFor="enabled">启用</label>
            <input id="enabled" type="checkbox" checked={form.enabled} onChange={(e) => this.update('enabled', e.target.checked)} />
          </div>
          <div className="field">
            <label htmlFor="date">日期</label>
            <input id="date" type="date" value={form.date} onChange={(e) => this.update('date', e.target.value)} />
          </div>
          <div className="field">
            <label />
            <button type="submit" className="btn primary">提交</button>{' '}
            <button type="button" className="btn" onClick={this.reset}>重置</button>
          </div>
        </form>
        {result && <div className="hint">{result}</div>}
      </div>
    );
  }
}
