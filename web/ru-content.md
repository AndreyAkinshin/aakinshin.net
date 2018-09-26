---
layout : ru-default
title : Блог Андрея Акиньшина / Содержание
permalink: /ru/content/
redirect_from:
- /ru/blog/content/
---
@model Pretzel.Logic.Templating.Context.PageContext

<h2>Содержание</h2>
<div>
<p><a href="/content/">Последние посты доступны только в английской версии блога</a></p>
@foreach(var year in Model.Site.RuPosts.Select(p => p.Date.Year).Distinct().OrderByDescending(y => y))
{
    var posts = Model.Site.RuPosts.Where(p => p.Date.Year == year).OrderByDescending(p => p.Date).ToList();
    if (posts.Count() > 0)
    {
        <h3 id="@year">@year</h3>
        <ul>
        @foreach(var post in posts)
        {
            <li><a href='@post.Url.Replace("index.html", "")'>@post.Title</a> <i>(@post.Date.ToString("dd MMMM", new System.Globalization.CultureInfo("ru-RU")))</i></li>
        }
        </ul>
    }
}
</div>
<hr />

<div>
@foreach(var tag in Model.Site.Tags.OrderByDescending(c => c.RuPosts.Count()))
{
    var posts = tag.RuPosts.Distinct().ToList();
    if (posts.Count() > 0)
    {
        <h3 id="@Pretzel.Logic.Extra.UrlAliasFilter.UrlAlias(tag.Name)">@tag.Name</h3>
        <ul>
        @foreach(var post in posts)
        {
            <li><a href='@post.Url.Replace("index.html", "")'>@post.Title</a> <i>(@post.Date.ToString("dd MMMM yyyy", new System.Globalization.CultureInfo("ru-RU")))</i></li>
        }
        </ul>
    }
}
</div>
<hr />

<p>Подписаться: <a href="/ru/rss.xml">RSS</a> <a href="/ru/atom.xml">Atom</a></p>