Sequel.migration do
  up do
    create_table :graph_nodes do
      primary_key :id
      Integer  :parent_id,  null: false, default: 0
      String   :label,      size: 32,    null:    false
      Integer  :level,      null: false, default: 1
      DateTime :expire_at,  null: false
      DateTime :updated_at, null: false
      unique   [:parent_id, :label], name: 'idx_parent_id_and_label_on_graph_nodes'
    end

    create_table :node_leaves do
      Integer  :node_id,    null: false, default: 0
      String   :item,       null: false
      Integer  :level,      null: false, default: 1
      DateTime :expire_at,  null: false
      DateTime :snooze_to,  null: false
      DateTime :updated_at, null: false
      primary_key [:node_id, :item]
    end

    create_table :messages do
      primary_key :id
      Integer  :node_id,    index: true,  null:    false
      String   :address,    size:  1024,  null:    false
      String   :type,       size:  32,    null:    false
      Integer  :level,      null:  false, default: 1
      String   :group,      null:  false
      String   :item,       null:  false
      String   :title,      null:  false
      String   :body,       text:  true,  null:    false
      String   :misc,       text:  true
      DateTime :expire_at,  null:  false
      DateTime :created_at, index: true, null: false
      DateTime :delivered_at
    end

    create_table :items do
      primary_key :id
      Integer  :message_id,  index: true,  null:    false, default: 0
      String   :address,     size:  1024,  null:    false
      String   :type,        size:  32,    null:    false
      Integer  :level,       null:  false, default: 1
      String   :group,       null:  false
      String   :name,        null:  false
      String   :message,     text:  true,  null:    false
      String   :misc,        text:  true
      DateTime :expire_at,   null:  false
      DateTime :received_at, index: true, null: false
    end
  end

  down do
    drop_table :graph_nodes, :node_leaves, :messages, :items
  end
end
