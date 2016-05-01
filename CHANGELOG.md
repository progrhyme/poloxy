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
