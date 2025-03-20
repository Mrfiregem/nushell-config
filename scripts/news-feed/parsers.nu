use std/xml ['xaccess']
use strutils/html.nu *

# Convert the output of `from xml` on an RSS file to a `JsonFeed` formatted record
def rss2table []: record -> record {
    let input = $in
    # Error if input isn't RSS
    if $input.tag? != 'rss' {
        error make {
            msg: 'RSS feed not detected'
            label: {span: (metadata $input).span, text: 'Missing <rss> tag'}
            help: 'Input should be the output of `from xml`'
        }
    }

    # Parse RSS record into JsonFeed-formatted table
    let channel = $input | xaccess [rss channel 0] | into record
    # Get feed metadata
    let feed_title = $channel | xaccess [channel title * *] | get -i 0
    let feed_desc = $channel | xaccess [channel description * *] | get -i 0
    let feed_home = $channel | xaccess [channel link * *] | get -i 0
    let feed_url = $channel | xaccess [channel link] | where attributes.rel? == 'self' | get -i 0 | get attributes.href
    # Parse feed entries
    let items = $channel | xaccess [channel item] | par-each --keep-order {|item|
        {
            title: ($item | xaccess [item title * *] | get -i 0)
            url: ($item | xaccess [item link * *] | get -i 0)
            summary: ($item | xaccess [item description * *] | get -i 0 | html decode | lines --skip-empty | str join ' / ')
        }
    }

    return {
        version: 'https://jsonfeed.org/version/1.1'
        title: $feed_title
        description: $feed_desc
        home_page_url: $feed_home
        feed_url: $feed_url
        items: $items
    }
}

export def "feed parse-rss" [link: string]: nothing -> record {
    http get $link | rss2table
}
