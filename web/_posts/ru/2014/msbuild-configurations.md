---
layout: ru-post
title: "Настраиваем конфигурации сборок в .NET"
date: "2014-02-08"
lang: ru
type: post
tags:
- ".NET"
- MSBuild
- Configurations
redirect_from:
- /ru/blog/dotnet/msbuild-configurations/
- /ru/blog/post/msbuild-configurations/
---

При создании нового проекта в Visual Studio по умолчанию вы получаете две конфигурации сборки: Debug и Release. И для большинства мелких проектов этого вполне достаточно. Но с ростом проекта может возникнуть потребность добавить дополнительные конфигурации. И хорошо, если нужно добавить одну-две новые конфигурации, а если их добрый десяток? А если при этом в солюшене находится штук 20 проектов, для каждого из которых эти конфигурации нужно настроить? В данном случае управлять параметрами сборки и модифицировать их становится достаточно сложно.

В этом посте будет рассмотрен способ, с помощью которого вы сможете немного упростить себе жизнь, существенно сократив описание конфигураций сборок.<!--more-->

Откройте csproj-файл одного из ваших проектов, вы найдёте в нём строчки такого вида:

``` xml
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
  <PlatformTarget>AnyCPU</PlatformTarget>
  <DebugSymbols>true</DebugSymbols>
  <DebugType>full</DebugType>
  <Optimize>false</Optimize>
  <OutputPath>bin\Debug\</OutputPath>
  <DefineConstants>DEBUG;TRACE</DefineConstants>
  <ErrorReport>prompt</ErrorReport>
  <WarningLevel>4</WarningLevel>
</PropertyGroup>
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
  <PlatformTarget>AnyCPU</PlatformTarget>
  <DebugType>pdbonly</DebugType>
  <Optimize>true</Optimize>
  <OutputPath>bin\Release\</OutputPath>
  <DefineConstants>TRACE</DefineConstants>
  <ErrorReport>prompt</ErrorReport>
  <WarningLevel>4</WarningLevel>
</PropertyGroup>
```

Первая проблема, которая стоит перед нами, состоит в том, что эти строчки дублируются (или практически дублируются) во всех проектах. К счастью, csproj-файлы поддерживают импорт конфигураций, так что создадим в корне солюшена файл `Configurations.targets` следующего содержания:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
    <PlatformTarget>AnyCPU</PlatformTarget>
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
    <PlatformTarget>AnyCPU</PlatformTarget>
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <OutputPath>bin\Release\</OutputPath>
    <DefineConstants>TRACE</DefineConstants>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup>
</Project>
```

После этого вы сможете заменить соответствующие строчки в исходном csproj-файле на

``` xml
<Import Project="..\Configurations.targets" />
```

Отлично, теперь дублирование описаний конфигураций ушло, можно сосредоточиться на редактировании единственного файла. Можно заметить, что в Debug и Release конфигурациях некоторые строчки всё ещё дублируются. Предполагается, что разработчик захочет настроить все эти параметры индивидуально для каждой конфигурации. Если такой потребности нет, то можно вынести дублирующиеся строчки в общую `PropertyGroup`:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <OutputPath>bin\Release\</OutputPath>
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
</Project>
```

Можно ли ещё что-нибудь улучшить? Давайте подумаем. Глаз сразу цепляется за `OutputPath`, который можно «вычислить» из названия конфигурации. При наличии двух конфигураций можно оставить для каждой индивидуальную настройку, но вот если конфигураций будет очень много, то здорово было бы сделать так, чтобы `OutputPath`
выводился из названия конфигурации. Тут нам на помощь приходит переменная `$(Configuration)`, с помощью которой это самое название можно узнать:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>    
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>    
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
</Project>
```

Замечательно, дублирование ушло. От чего ещё можно избавиться? Как правило, выставляемые свойства зависят только от конфигурации, изменение платформы ни на что не влияет. Давайте уберём лишнее условие:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <PropertyGroup Condition="'$(Configuration)' == 'Debug' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>    
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)' == 'Release' ">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>    
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
</Project>
```

Теперь добавим новых конфигураций. Положим, мы хотим ввести в наше приложение Demo-режим, в котором будут доступны не все функции. Demo-режим также может потребоваться отладить, поэтому разумно создать конфигурации `DebugDemo` и `ReleaseDemo`. А ещё, к примеру, мы хотим ввести режим сборки, при котором от пользователя будет требоваться лицензия. Demo-версию также может понадобится лицензировать, так что мы имеем ещё 4 конфигурации: `DebugLicense`, `ReleaseLicense`, `DebugDemoLicense`, `ReleaseDemoLicense` (данная ситуация приведена только для примера, в вашем проекте может быть всё иначе). `Demo` и `License` будут добавлять новые переменные в `DefineConstatns`. Казалось бы, для 8 конфигураций нужно сделать 8 отдельных `PropertyGroup`, но что-то внутри сознания сразу начинает протестовать. К счастью, в `Condition` можно разместить более сложное условие, нежели простое сравнение. В данном примере будем искать заданную подстроку в названии конфигурации:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <!-- Conditional -->
  <PropertyGroup Condition="$(Configuration.Contains('Debug'))">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>    
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Release'))">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>    
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('License'))">
    <DefineConstants>$(DefineConstants);LICENSE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Demo'))">
    <DefineConstants>$(DefineConstants);DEMO</DefineConstants>
  </PropertyGroup>  
</Project>
```

Выглядит вполне неплохо. Но только образовалась проблема: Visual Studio теперь «не видит» список доступных конфигураций. Эту проблему можно решить, добавив пустых `PropertyGroup` c таким же `Condition` , как были вначале. При этом можно добавлять не все возможные конфигурации, а только те, которые вы реально будете использовать при работе. Например, мы не хотим отлаживать `Demo` и `License` конфигурации, тогда можно написать так:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <!-- Conditional -->
  <PropertyGroup Condition="$(Configuration.Contains('Debug'))">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>    
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Release'))">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>    
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('License'))">
    <DefineConstants>$(DefineConstants);LICENSE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Demo'))">
    <DefineConstants>$(DefineConstants);DEMO</DefineConstants>
  </PropertyGroup>  

  <!-- Available -->
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseDemo|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseLicense|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseDemoLicense|AnyCPU'" />
</Project>
```

Если у вас есть врождённая ненависть к дублированию чего угодно, то в получившийся файл можно также вынести дополнительные свойства, которые дублируются во всех проектах. Например так:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Release</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>    
    <TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
    <SolutionDir Condition="$(SolutionDir) == '' Or $(SolutionDir) == '*Undefined*'">..\</SolutionDir>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <!-- Conditional -->
  <PropertyGroup Condition="$(Configuration.Contains('Debug'))">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Release'))">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('License'))">
    <DefineConstants>$(DefineConstants);LICENSE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Demo'))">
    <DefineConstants>$(DefineConstants);DEMO</DefineConstants>
  </PropertyGroup>  

  <!-- Available -->
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseDemo|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseLicense|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseDemoLicense|AnyCPU'" />
</Project>
```

Теперь точно всё дублирование ушло, а настраивать конфигурации стало легко и просто. Хочется отметить, что совершенно не обязательно данный подход подойдёт именно вам, многие проекты отлично пишутся и без правки конфигураций. А иногда каждую конфигурацию для каждого проекта и каждой платформы приходится настраивать вручную — в этом случае не особо получится сэкономить на удалении дублирования. Но если всё-таки возникла проблема с настройкой большого количества конфигураций для большого количество проектов, то, возможно, этот способ вам пригодится. Также будет полезно почитать справочные сведения о сборке в MSDN:

### Ссылки

* [Справочные сведения о MSBuild](http://msdn.microsoft.com/ru-ru/library/0k6kkbsd.aspx)
* [Условные конструкции MSBuild](http://msdn.microsoft.com/ru-ru/library/ms164307.aspx)
* [Условия MSBuild](http://msdn.microsoft.com/ru-ru/library/7szfhaft.aspx)
* [Функции свойств](http://msdn.microsoft.com/ru-ru/library/dd633440.aspx)
* [Использование переменных среды в построении](http://msdn.microsoft.com/ru-ru/library/ms171459.aspx)
* [Общие свойства проектов MSBuild](http://msdn.microsoft.com/ru-ru/library/bb629394.aspx)
* [Общие элементы проектов MSBuild](http://msdn.microsoft.com/ru-ru/library/bb629388.aspx)