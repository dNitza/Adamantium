# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table :trips do
      add_column :subtitle, :text
    end
  end
end
