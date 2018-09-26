---
layout : ru-default
title : Блог Андрея Акиньшина
permalink: /ru/posts/
paginate: 10
paginate_lang: ru
paginate_type: post
paginate_link: "/ru/posts/page/:page/"
redirect_from:
- /ru/blog/
---
@model Pretzel.Logic.Templating.Context.PageContext

<p style="font-size:150%"><a href="/blog/">Последние посты доступны только в английской версии блога</a></p>
<hr />
<div class="blog-main">
@foreach (var post in Model.Paginator.Posts)
{
    var excerpt = (string)post.Bag["excerpt"];
    <div class="blog-post">
        <h2 class="blog-post-title"><a href='@post.Url.Replace("index.html", "")'>@post.Title</a></h2>
        <span class="blog-post-meta">
          <b>Дата:</b> @post.Date.ToString("dd MMMM yyyy", new System.Globalization.CultureInfo("ru-RU")).
          <b>Теги:</b>
            @foreach(var tag in post.Tags)
            {
                <a href="/ru/tags/@Pretzel.Logic.Extra.UrlAliasFilter.UrlAlias(tag)"><span class="badge badge-pill badge-info">@tag</span></a>
            }
        </span><br /><br />
        @Raw(excerpt)
        <a href='@post.Url.Replace("index.html", "")'>Читать дальше</a><br /><br />
        <hr />
    </div>
}
</div>

<nav>
  <ul class="pagination">
    @if (Model.Paginator.PreviousPageUrl != null)
    {
      <li class="page-item">
        <a class="page-link" href='@Model.Paginator.PreviousPageUrl.Replace("index.html", "")' aria-label="Назад">
          <span aria-hidden="true">&laquo;</span>
          <span class="sr-only">Назад</span>
        </a>
      </li>
    }
    @if (Model.Paginator.PreviousPageUrl == null)
    {
      <li class="page-item disabled">
        <a class="page-link" href="#" aria-label="Назад">
          <span aria-hidden="true">&laquo;</span>
          <span class="sr-only">Назад</span>
        </a>
      </li>
    }
    @for (int i = 1; i <= Model.Paginator.TotalPages; i++)
    {
      var link = i == 1 ? "/ru/posts/" : "/ru/posts/page/" + i.ToString() + "/";
      if (Model.Paginator.Page == i)
      {
        <li class="page-item active">
          <a class="page-link" href="@link">@i <span class="sr-only">(current)</span></a>
        </li>
      }
      if (Model.Paginator.Page != i)
      {
        <li class="page-item"><a class="page-link" href="@link">@i</a></li>
      }
    }
    @if (Model.Paginator.NextPageUrl != null)
    {
      <li class="page-item">
        <a class="page-link" href='@Model.Paginator.NextPageUrl.Replace("index.html", "")' aria-label="Вперёд">
          <span aria-hidden="true">&raquo;</span>
          <span class="sr-only">Вперёд</span>
        </a>
      </li>
    }
    @if (Model.Paginator.NextPageUrl == null)
    {
      <li class="page-item disabled">
        <a class="page-link" href="#" aria-label="Вперёд">
          <span aria-hidden="true">&raquo;</span>
          <span class="sr-only">Вперёд</span>
        </a>
      </li>
    }
  </ul>
</nav>

<hr />
<p>Подписаться: <a href="/ru/rss.xml">RSS</a> <a href="/ru/atom.xml">Atom</a></p>