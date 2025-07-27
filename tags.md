---
layout: page
title: Index
permalink: /tags
---


# Projects

{% assign project_slugs = '' | split: '' %}
{% assign site_pages_sorted = site.pages | sort: "title" %}

{% for page in site_pages_sorted %}
  {% if page.path contains "projects" %}
  {% assign project_title = page.title %}
  <a name="{{project_title | slugify}}"></a>
  <a class="smallcaps nav" href="{{ page.url }}">{{project_title}}</a> - {{ page.description }}
  {% assign project_slug = project_title | slugify %}
  {% assign project_slugs = project_slugs | append: project_title | slugify %}

  {%- for post in site.posts -%}
    {% assign post_proj_name = post.categories.last | slugify %}
    {%- if post_proj_name == project_slug -%}
[{{ post.title }}]({{ post.url }}) <span class="eighthgutter"> </span>
    {%- endif -%}
  {%- endfor -%}

  {% endif %}
{% endfor %}

{%- assign site_posts_sorted = site.posts | sort: "title" -%}

# Other categories

{% assign site_categories_names = '' | split: '' %}
{% for cat in site.categories %}
  {% assign cat_name = cat | first %}
  {% assign site_categories_names = site_categories_names | append: '|' | append: cat_name %}
{% endfor %}

{% assign site_categories_sorted = site_categories_names | split: '|' | sort %}
{% for cat_name in site_categories_sorted %}
  {% assign cat_slug = cat_name | slugify %}

  {%- if cat_slug contains "projects" -%}
  {%- elsif project_slugs contains cat_slug -%}
  {%- else -%}
  <a name="{{cat_slug}}"></a>
  <a class="smallcaps nav" href="{{site.baseurl}}/tags.html#{{ cat_slug }}">{{cat_name}}:</a>
  {%- for post in site_posts_sorted -%}
    {%- if post.categories contains cat_name -%}
<span class="eighthgutter"> </span> [{{ post.title }}]({{post.url}})
    {%- endif -%}
  {%- endfor -%}
  {%- endif -%}
{% endfor %}


# Tags

{% assign site_tags_sorted = site.tags | sort %}
{% for tag in site_tags_sorted %}
  {% assign tag_name = tag | first %}
  {% assign tag_slug = tag_name | slugify %}
  <a name="{{tag_slug}}"></a>
  <a class="smallcaps nav" href="{{site.baseurl}}/tags.html#{{tag_slug}}">#{{tag_name}}:</a>
  {%- for post in site_posts_sorted -%}
    {%- if post.tags contains tag_name -%}
<span class="eighthgutter"> </span> [{{ post.title }}]({{post.url}})
    {%- endif -%}
  {%- endfor -%}
{% endfor %}

