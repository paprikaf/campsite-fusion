# Architecture Analysis Report

## Applications Found

### @campsite/site
- **Path:** apps/site
- **Framework:** nextjs
- **Routes:** 9
  - / (static) - landing page
  - /blog (static) - blog listing
  - /blog/[slug] (dynamic) - blog post detail
  - /changelog (static) - changelog listing
  - /changelog/[slug] (dynamic) - changelog detail
  - ... and 4 more


### @campsite/web
- **Path:** apps/web
- **Framework:** nextjs
- **Routes:** 6
  - / (static) - app redirect/index
  - /[org] (dynamic) - organization dashboard
  - /[org]/posts/[postId] (dynamic) - post detail view
  - /[org]/projects/[projectId] (dynamic) - project detail view
  - /[org]/calls/[callId] (dynamic) - call detail view
  - ... and 1 more


### @campsite/figma
- **Path:** apps/figma
- **Framework:** other
- **Routes:** 0




## Current CMS
- **Type:** sanity (95% confidence)
- **Content Models:** 1
  - glossary: category, title, slug, publishedAt, shortDescription, markdown

## Migration Plan

### Builder Models to Create

- **glossary-entry** (data)
  - Fields: category, title, slug, publishedAt, shortDescription, content
  


- **blog-post** (data)
  - Fields: title, description, author, publishedAt, posterLight, posterDark, content, pinned
  


- **page** (page)
  - Fields: title, description, blocks
  - Targeting: urlPath


### Integration Steps

1. **Install Builder.io SDK**
   Add @builder.io/react and @builder.io/sdk-react to package.json
   
   ```typescript
   npm install @builder.io/react @builder.io/sdk-react
   ```



2. **Set up Builder configuration**
   Create Builder client and configure API key
   
   ```typescript
   // lib/builder.ts
import { builder } from '@builder.io/react'

builder.init(process.env.BUILDER_PUBLIC_KEY!)

export { builder }
   ```



3. **Create data migration script**
   Script to migrate Sanity glossary entries to Builder data models
   
   ```typescript
   // scripts/migrate-sanity-to-builder.ts
import { builder } from '../lib/builder'
import { client as sanityClient } from '../sanity/client'

async function migrateGlossaryEntries() {
  const entries = await sanityClient.fetch('*[_type == "glossary"]')
  
  for (const entry of entries) {
    await builder.create('glossary-entry', {
      data: {
        title: entry.title,
        category: entry.category,
        slug: entry.slug.current,
        publishedAt: entry.publishedAt,
        shortDescription: entry.shortDescription,
        content: convertMarkdownToRichText(entry.markdown)
      }
    })
  }
}
   ```



4. **Update glossary listing page**
   Replace Sanity queries with Builder data fetching
   
   ```typescript
   // app/glossary/slack/(index)/page.tsx
import { builder } from '@builder.io/react'

export default async function GlossaryPage() {
  const entries = await builder.getAll('glossary-entry', {
    query: {
      'data.category': 'slack'
    },
    options: {
      sort: {
        'data.publishedAt': -1
      }
    }
  })

  return <GlossaryIndex posts={entries} />
}
   ```



5. **Update glossary detail pages**
   Replace Sanity queries with Builder data fetching for individual entries
   
   ```typescript
   // app/glossary/slack/[slug]/page.tsx
import { builder } from '@builder.io/react'

export default async function GlossaryEntryPage({ params }: { params: { slug: string } }) {
  const entry = await builder.get('glossary-entry', {
    query: {
      'data.slug': params.slug,
      'data.category': 'slack'
    }
  })

  if (!entry) notFound()

  return (
    <article>
      <h1>{entry.data.title}</h1>
      <BuilderComponent model="glossary-entry" content={entry} />
    </article>
  )
}
   ```



6. **Migrate blog posts**
   Convert MDX files to Builder blog-post data model
   
   ```typescript
   // scripts/migrate-blog-posts.ts
import fs from 'fs'
import matter from 'gray-matter'
import { builder } from '../lib/builder'

async function migrateBlogPosts() {
  const files = fs.readdirSync('app/blog/_cms')
  
  for (const file of files) {
    const content = fs.readFileSync(`app/blog/_cms/${file}`, 'utf-8')
    const { data, content: mdxContent } = matter(content)
    
    await builder.create('blog-post', {
      data: {
        title: data.title,
        description: data.description,
        author: data.author,
        publishedAt: data.publishedAt,
        content: convertMdxToRichText(mdxContent),
        pinned: data.pinned || false
      }
    })
  }
}
   ```



7. **Create Builder page models**
   Set up page models for marketing pages with visual editing
   
   ```typescript
   // components/BuilderPage.tsx
import { BuilderComponent, builder } from '@builder.io/react'

interface BuilderPageProps {
  page: any
}

export function BuilderPage({ page }: BuilderPageProps) {
  return (
    <BuilderComponent
      model="page"
      content={page}
    />
  )
}

// For pages like pricing, contact, etc.
export async function getBuilderPage(urlPath: string) {
  return await builder
    .get('page', {
      userAttributes: {
        urlPath
      }
    })
    .toPromise()
}
   ```



8. **Update routing and fallbacks**
   Implement Builder page routing with Next.js catch-all routes
   
   ```typescript
   // app/[[...page]]/page.tsx
import { BuilderComponent, builder } from '@builder.io/react'
import { notFound } from 'next/navigation'

export default async function CatchAllPage({ params }: { params: { page?: string[] } }) {
  const urlPath = '/' + (params.page?.join('/') || '')
  
  const page = await builder
    .get('page', {
      userAttributes: {
        urlPath
      }
    })
    .toPromise()

  if (!page) {
    return notFound()
  }

  return <BuilderComponent model="page" content={page} />
}
   ```



### Estimated Effort
3-4 days

## Recommendations
- Start with migrating the Sanity glossary entries to Builder data models as they are well-structured and limited in scope
- Set up Builder data models before starting migration to ensure proper field mapping
- Consider keeping Sanity running in parallel during migration for rollback capability
- Migrate blog posts from MDX files to Builder for better content management
- Use Builder's visual editor for marketing pages (pricing, contact) to enable non-technical team members to make updates
- Implement proper preview/draft functionality using Builder's preview API
- Set up Builder webhooks for cache invalidation and revalidation
- Consider migrating the changelog system from GitHub releases to Builder for better control
- Test the migration thoroughly with a staging environment before going live
- Document the new content workflows for the team
