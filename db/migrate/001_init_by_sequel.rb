Sequel.migration do
  up do
    create_table :graph_nodes do
      primary_key :id
      Integer :parent_id
    end

    create_table :node_children do
      Integer :node_id
      Integer :child_id
      primary_key [:node_id, :child_id]
    end

    create_table :messages do
      primary_key :id
      Integer  :node_id,      index: true
      String   :address,      size:  1024
      String   :type,         size:  32
      String   :kind,         size:  32
      String   :title
      String   :body,         text:  true
      String   :misc,         text:  true
      DateTime :delivered_at, index: true
    end

    create_table :items do
      primary_key :id
      Integer  :message_id,  index: true
      String   :address,     size:  1024
      String   :type,        size:  32
      String   :kind,        size:  32
      String   :name
      String   :message,     text:  true
      String   :misc,        text:  true
      DateTime :received_at, index: true
    end
  end

  down do
    drop_table :graph_nodes, :node_children, :messages, :items
  end
end
