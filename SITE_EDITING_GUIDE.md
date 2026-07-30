# 个人主页维护指南

这套站点继续使用 Jekyll / al-folio 作为内容与论文数据底座，但首页、双语导航、教师主页布局和视觉样式已经单独重构。日常更新通常不需要改 Liquid 模板。

## 最常修改的位置

- `_data/profile.yml`：姓名、职称、单位、邮箱、个人简介、教育经历、照片和学术链接。
- `_data/research.yml`：三个研究方向及其代表成果。
- `_data/featured_publications.yml`：首页代表论文与系统。
- `_bibliography/papers.bib`：完整论文列表。
- `_data/resources.yml`：代码、数据集、系统与教程。
- `_data/activities.yml`：奖项与学术服务。
- `_data/news.yml`：中英文动态。
- `_pages/*.md`：中英文页面标题、简介、URL 和 SEO 描述。
- `_sass/_faculty.scss`：本次重构使用的北邮蓝视觉系统与响应式布局。

中英文客观事实应保持一致；研究叙事、学生信息与栏目说明可以按受众分别撰写，不必逐句翻译。

## 照片

当前首页使用：

- `assets/img/guoxuan-chi-portrait.webp`：桌面端 4:5 肖像。
- `assets/img/guoxuan-chi-portrait-480.webp`：移动端版本。
- `assets/img/guoxuan-chi-avatar.webp`：方形头像备用。
- `assets/img/guoxuan-chi-portrait-original.png`：高质量原图存档。

替换照片时应维持相同文件名和比例，可避免修改模板。

论文与项目配图位于：

- `assets/img/research/`：首页研究方向、代表性论文和项目使用的真实论文图或项目图。
- `assets/img/publication_preview/`：完整论文列表中的缩略图；在 `papers.bib` 中通过 `preview={文件名.webp}` 引用。

新增图片建议使用 8:5 横向比例、浅色背景和 WebP 格式。论文图应优先截取系统框架、实验场景或关键结果，不使用装饰性图库图片。

## 中英文默认语言

英文主页仍为根路径 `/`，中文主页为 `/zh/`。首次访问英文根路径时，`assets/js/language-routing.js` 会读取浏览器首选语言：若为中文，则转到中文首页。用户手动点击 `中文 / EN` 后，选择会保存在浏览器本地，之后优先尊重用户选择。该逻辑不读取 IP、地理位置或精确位置。

## 本地构建

需要 Ruby 3.2、Bundler 和 Node.js：

```powershell
bundle install
bundle exec jekyll build
bundle exec jekyll serve
```

本地预览地址通常为 `http://127.0.0.1:4000/`，中文首页为 `/zh/`。

## 发布

`.github/workflows/deploy.yml` 已配置为在源代码推送到 `main` 或 `master` 后构建，并将 `_site` 发布到 `gh-pages` 分支。

当前目录中的 `_guoxuan-chi.github.io/` 是旧的静态发布仓库副本，不是本次重构的源代码仓库；在切换发布方式前，不要直接用它覆盖当前源文件。建议先确认 GitHub Pages 的发布来源为 `gh-pages`，再将本目录作为正式源代码仓库推送。

## 发布前仍需确认的事实

- 是否继续公开使用 `chiguoxuan@gmail.com`，或替换为北邮邮箱。
- 最新办公室/实验室信息（如需要公开）。
- 最新中英文 CV 文件和命名。
- 招生、科研实习、课程与学生指导信息何时开放。
