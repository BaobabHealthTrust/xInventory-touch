class UniqueField < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<EOF
      ALTER IGNORE TABLE items ADD UNIQUE (serial_number);
EOF

    ActiveRecord::Base.connection.execute <<EOF
      ALTER IGNORE TABLE items ADD UNIQUE (barcode);
EOF

  end

  def down
    ActiveRecord::Base.connection.execute <<EOF
      ALTER TABLE items DROP INDEX serial_number;
EOF

    ActiveRecord::Base.connection.execute <<EOF
      ALTER TABLE items DROP INDEX barcode;
EOF

  end
end
