# 个人主页维护指南

这套站点继续使用 Jekyll / al-folio 作为内容与论文数据底座，但首页、双语导航、教师主页布局和视觉样式已经单独重构。日常更新通常不需要改 Liquid 模板。

## 最常修改的位置

- `_data/profile.yml`：姓名、职称、单位、邮箱、个人简介、教育经历、照片和学术链接。
- `_data/research.yml`：三个研究方向及其代表成果。
- `_data/featured_publications.yml`：首页代表论文与系统。
- `_bibliography/papers.bib`：完整论文列表。
- `_data/resources.yml`：代码、数据集、系统与教程。
- `_data/activities.yml`：会议组织与主持（`conferences`）、奖项（`honors`）与学术服务。
- `_data/news.yml`：中英文动态。
- `_pages/*.md`：中英文页面标题、简介、URL 和 SEO 描述。
- `_sass/_faculty.scss`：本次重构使用的北邮蓝视觉系统与响应式布局。

中英文客观事实应保持一致；研究叙事、学生信息与栏目说明可以按受众分别撰写，不必逐句翻译。

首页简介按教育经历、研究与项目、获奖分段，`summary_en` / `summary_zh` 使用 `<p>` 包裹各段。先写博士导师杨铮，再写博士后期间与刘云浩共同工作的经历，并保留两位老师的学术主页链接。杨铮也是博士后导师，不要将 `working with Prof. Yunhao Liu` 改写成正式导师关系。程序委员会和审稿等学术服务只在学术活动页展示。

简介中的研究方向统一表述为“主要研究方向为物联网感知、通信与具身导航系统。”英文对应为“My research focuses on IoT sensing, communications, and embodied navigation systems.”生成式模型属于具体工作的技术方法，不作为个人研究定位的总标题。简介、荣誉列表和获奖动态中的奖项均用纯文本呈现，不加超链接，不显示获奖人排名。数据中的官方奖项 `url` 只作来源记录。

页面标题下不显示维护性或概括性说明文字；`description` 只供 SEO 元数据使用。研究页不放大段引言、“未来议题”或重复的关键词标签；直接展示研究方向、相关工作、系统与资源。2027级硕士招生已结束，首页与合作页不再显示该招生公告；不显示尚无具体内容的“课程与指导”占位栏目。本指南只保留在源代码中，不随网站发布。

页面标题和大栏目之间使用留白，不再添加装饰性分隔线；列表只在相邻记录之间保留单条细线，不封闭列表上下边缘。论文采用无外框列表，避免相邻卡片的上下边框形成双线。删除内容时同时检查空容器、边框与间距，避免留下没有内容的分隔线。

## 照片

当前首页使用：

- `assets/img/guoxuan-chi-portrait.webp`：桌面端 4:5 肖像。
- `assets/img/guoxuan-chi-portrait-480.webp`：移动端版本。
- `assets/img/guoxuan-chi-avatar.webp`：方形头像备用。
- `assets/img/guoxuan-chi-portrait-original.png`：高质量原图存档。

2026-10-27 网站与中英文简历已统一使用用户最后提供的灰色背景肖像。母版按原文件保存；网页只生成对应尺寸与格式的图片，简历直接引用同一张母版。

替换照片时应维持相同文件名和比例，可避免修改模板。

论文与项目配图位于：

- `assets/img/research/`：首页研究方向、代表性论文和项目使用的真实论文图或项目图。
- `assets/img/publication_preview/`：完整论文列表中的缩略图；在 `papers.bib` 中通过 `preview={文件名.webp}` 引用。

新增图片建议使用 8:5 横向比例、浅色背景和 WebP 格式。论文图应优先截取系统框架、实验场景或关键结果，不使用装饰性图库图片。

会议活动照片使用原始横向构图，保留完整会场信息，放在 `assets/img/activities/`。会议主持与邀请报告合并在中英文“学术活动”的“会议主持与邀请报告”栏目，统一按日期倒序显示；桌面端照片宽约 240 像素，手机端不超过 280 像素，点击可看原图。首页动态通过“照片与详情”链接到相应记录：

- `hmcc-hhme-2026-session-chair.webp`：长沙 HMCC / HHME 2026，原照片仅转为 WebP。
- `cncc-2026-chair.webp`：成都 CNCC 2026，轻度校正青蓝偏色和面部肤色；内置 ImageGen 处理的母版为同目录 `cncc-2026-chair-retouched.png`。

`activities.conferences` 与 `talks` 合并后按日期倒序渲染，照片统一使用 `images` 数组，含 `src`、中英文 `alt` 和可选的 `width` / `height`。`news` 同样按日期倒序渲染。只有会期、没有具体主持日期时，填写 `date` 和 `date_end` 表示会议起止时间，不把整个会期误写成具体主持日。动态的 `conference_id` 对应会议记录的 `id`，会自动生成当前语言的照片链接；`url` 保存官方来源。

2026-10-27 已将完成的 TCOM 综述宣传稿、封面、工作脚本和相关插图缓存移到项目外的 `Z:\项目汇总\TCOM宣传稿归档-20261027\`。`output/` 与 `tmp/` 均不参与站点构建。论文列表与学术审稿服务中的 TCOM 记录仍属于个人科研主页内容。

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

### Google Scholar 的作者与标题边界

2026-09-22 检查发现，旧版 `_bibliography/papers.bib` 把 `<strong>` 直接写进作者姓名；列表还只在初始 HTML 中显示前三位作者，其余作者放在点击事件字符串中。Chameleon 的第四位作者恰好是 Guoxuan Chi，与截图的截断位置一致。这是有证据支持的高风险解析结构，但截图没有错误记录的来源 URL，不能证明 Google 当时具体解析了哪份网页、PDF 或他处引用。

当前版本的规则：

- `author` 只写姓名与已有的贡献标记，不要嵌入 `<strong>`、`<b>`、`<em>` 等 HTML。构建器会拒绝作者字段中的 HTML。
- 所有作者在初始 HTML 中完整显示；`publication_authors.liquid` 统一渲染姓名。本站作者只用下划线区分，不改变姓名的字体、字号或字重；贡献标记以独立上标显示，机器元数据会去掉这些标记。
- 标题与作者分别使用 `citation_title`、`citation_author` 类。多篇论文列表不输出页面级 `citation_*` meta 标签，避免把多篇论文混成一篇。
- 有完整 `abstract` 的条目自动生成 `/assets/pdf/<BibTeX key>.html` 单篇页面，包含独立的 `citation_title`、每位作者各一个 `citation_author`、年份及可用的 DOI、刊物、页码等字段。摘要直接可见，列表标题链接到该页面，页面也进入 sitemap。
- 本地论文 PDF 与对应摘要页同在 `/assets/pdf/`，通过绝对地址 `citation_pdf_url` 关联。域名和子路径取自 `_config.yml` 的 `url`、`baseurl`，不要硬编码部署地址。外站 PDF 不冒充同目录文件。
- 没有完整摘要的条目直接链接已有的出版社/arXiv/DOI 页面；不要用一句简介填充 `abstract`，也不要把缺少摘要的页面伪装成完整论文记录。目前两篇 2026 年论文也使用这个策略，完整作者名单同样经过检查。

本次还根据 [Chameleon 的 arXiv 记录](https://arxiv.org/abs/2503.07485) 补齐 Hao Zhao，并根据 [Delving 的 arXiv 记录](https://arxiv.org/abs/2507.18498) 补齐最后四位作者。Chameleon 的会议 DOI 和页码依据 [出版社登记信息](https://api.crossref.org/works/10.1109/ICRA55743.2025.11127684) 补入。两条旧的手写 BibTeX 覆盖内容已移除，Bib 按钮使用当前条目生成，避免页面显示会议论文而导出预印本、作者仍为 `others` 的冲突。

构建后运行回归检查：

```powershell
bundle exec jekyll build
bundle exec ruby bin/check-scholar.rb
```

检查覆盖中英文完整作者名单、标题、单篇 meta 标签、摘要可见性、站内链接、canonical、sitemap、PDF 地址和构建保护。2026-09-22 已验证中英文各 19 篇论文、10 个单篇摘要页和 10 个对应 PDF。另已修复列表中月份跨条目残留的问题。检查子路径部署时，可传入对应构建目录、baseurl 和 url：

```powershell
bundle exec ruby bin/check-scholar.rb tmp/scholar-audit/subpath /~guoxuan https://tns.thss.tsinghua.edu.cn
```

依据：[Google Scholar 官方收录指南](https://scholar.google.com/intl/en/scholar/inclusion.html#indexing)。这些检查验证本站输出，不模拟 Google 的私有解析器，也不保证历史错误记录立即消失。若旧清华主页继续在线，应同步修复那里的源文件并重新发布；只更新 GitHub Pages 不会改变旧网址。已经产生的错误条目需要等待重新抓取，或在 Scholar 个人资料中核实后合并重复项。

### 站点发布流程

`.github/workflows/deploy.yml` 已配置为在源代码推送到 `main` 或 `master` 后构建，并将 `_site` 发布到 `gh-pages` 分支。

已确认 GitHub Pages 使用 `gh-pages` 分支的根目录发布，`main` 分支保存 Jekyll 源码。当前项目主目录作为正式源代码目录使用；`_guoxuan-chi.github.io/` 只保留旧静态副本，不用于发布。发布前检查中英文页面、论文元数据和两份 CV；发布后确认线上照片、CV 文件与本地一致，并检查旧简历和微信二维码不再公开提供。

## 后续维护

- 当前公开邮箱仅为 `chiguoxuan@bupt.edu.cn`，办公室为明光楼705。网站与公开简历不显示私人邮箱、手机号或微信；旧版 CV 和微信二维码图片保留在本地但排除出网站构建。
- 2026-10-27 已依据用户提供的 Overleaf 项目更新中英文 CV，各3页，均包含19篇论文；中文保留原有两项专利。各语言原稿前六篇代表作的顺序保持不变，新增论文放在代表作之后，并保留完整作者与共同一作、通讯作者标记。
- 任职日期由用户确认：2026年6月结束清华博士后，2026年7月起任职北邮。博士后与博士阶段的导师均为杨铮教授。
- 当前英文 PDF 为 `assets/pdf/Guoxuan-CV-20261027-EN.pdf`，中文 PDF 为 `assets/pdf/Guoxuan-CV-20261027-ZH.pdf`。`_data/profile.yml` 的 `cv_en` / `cv_zh` 控制首页下载，`_data/navigation.yml` 控制中英文导航下载，`_config.yml` 的 `cv` 保留英文默认值。
- 可编辑源码位于 `cv/2026-10-27/`，源码包为 `cv/Resume_Updated_20261027.zip`。上传 Overleaf 后选择 `resume-en.tex` 或 `resume-zh.tex` 为主文件，编译器使用 XeLaTeX。使用原模板和网站同款肖像，所需 IBM Plex / Noto Serif CJK 字体随项目保留；`cv/` 不参与网站构建，网页只提供最终 PDF。
- 中英文网站与简历中的 CCF 自然科学一等奖均只显示奖项名称，不显示获奖人排名。论文作者顺序和共同一作、通讯作者标记继续保留。
- 北京邮电大学2019年奖项的名称为“本科生特等奖学金”，不要写成“特殊贡献奖学金”。
- 新的招生公告和课程信息待用户给出具体内容后再添加。
