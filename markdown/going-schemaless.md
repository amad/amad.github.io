---
title: Tips for schemaless design
description: Recommendations that can be taken into account before going schemaless
keywords: schemaless, lessons learned
date: 2017-03-06
redirect_from: "/blog/going_schemaless.html"
permalink: "/blog/going-schemaless.html"
---

With schemaless databases, you benefit from transparent database adjustments. They do not enforce any structure for your data, but in most cases, you will have a reasonably consistent model. The software industry is getting agiler also means that we are dealing with more ever-changing entities. And probably that is one of the reasons that schemaless databases are a good fit.

Schemaless databases have been around for a while, but comparing with the Relational model, they are still quite new, and a lot of development teams do not understand the tradeoffs.

I want to list a few things that I learned working on schemaless projects in the past few years.

In most cases, there is a consistent model (at least in your code!). If your project is not one of the exceptions, most of these recommendations are going to help you down the road. But some of them might differ in some cases.

## While starting:

* Think about application requirements. You don't have to define your model, but you should have a rough idea of it.
* Find a right performance balance. Do you want to have read optimized model or write optimized model?
* Make sure your team understands shard keys, and you know how your database is going to handle sharding and partitioning. Databases are using similar patterns but implemented differently.
* Investigate analytics and reporting expectations.
* Make sure the ops team does support your database technology.
* Be careful with your shard keys from the beginning. Understand performance impact of your model on distributed systems.

## While building:

* It is better if your code/API can enforce an explicit schema because your database is not going to give you an error when your data does not fit your implicit schema. This way your code is going to make less assumptions about the data structure.
* If you have downstream dependencies, consider using triggers (event-streams in some databases). Schemaless can be a perfect source-of-truth data store when using triggers. But do not forget to document downstream dependencies, their requirements, integration method, and the way you are notifying them. It will help you in change management, especially with schema changes.
* You can migrate data during reading or migrate all data in one go (Some databases have tools for that. However in some cases, you have to build an ETL process). Removing support for the old data structure from your code is essential after migration.
* Wrap your schemaless data with determined methods wherever you want to use your data. You want to make sure fewer part of the software is dependent on the structure. Data access layer is the first place to start.
* Do not mix custom fields or meta-information with your implicit schema (ex. fields that are only to display something in the UI, any information that base software is not using. dates for instance). An easy way is to put them under a meta information namespace in your JSON object.
* If you have to deal with non-uniform data where fields differ between individual records, (events are a good example), try to add sub-types. Thus, it is easier to know what properties are expected depending on the sub-type. If you have many changes in your data structure and it is natural for your project, you can think about versioning, so your code can behave base on version instead of attributes.
* Don't get paranoid about schema; it is going to be fine.
