## 0.3.3 (2016/5/9)

Feature:

- Implement new CLI `poloxy-cli` which purges old expired data

Change:

- Database:
  - Change index column of `items` table from `received_at` to `expire_at`
  - Change index column of `messages` table from `created_at` to `expire_at`

## 0.3.2 (2016/5/9)

Improve:

- Config: support natural time expressions in config file
- WebUI: show `snooze_to` field of `node_leaves` in `/board/:group` page

## 0.3.1 (2016/5/8)

Change:

- API:
  - `POST /v1/item`: change the format of `misc` from _String_ to _JSON_

## 0.3.0 (2016/5/8)

Feature:

- Implement alerts snoozing

## 0.2.1 (2016/5/3)

Fix:

- `messages.level` should be level of last item, but was max level of buffered
  items. (#7)

Improve:

- WebUI:
  - Add non-expired alerts info of `:group` on `/board/:group` page
  - Add group column for items table in `/message/:id` page

## 0.2.0 (2016/5/3)

Feature:

- Implement `Mail` delivery-type to deliver alerts via SMTP
  - Set `messages.misc` parameter by received `items.misc`

Change:

- Use ruby v2.3.1 as `.ruby-version` and re-bundle with v1.12.1
- Deeply merge config params of file with default params using `deep_merge` gem

## 0.1.2 (2016/5/2)

Feature:

- Implement `PerAddress` config option for `deliver.item.merger`

Change:

- Don't update graph data for merged messages because it has no matter with
  happend alerts.

Bug Fix:

- `P::MessageContainer#append` - add appended `Message.items.length` for `@group_items`

Internal Improvements:

- Refactor and add tests for `Poloxy::ItemMerge*` classes

## 0.1.1 (2016/4/30)

Feature:

- Implement `PerGroup` config option for `deliver.item.merger`

And a few minor bug fix and change of Web UI.

## 0.1.0 (2016/4/30)

Initial release.
