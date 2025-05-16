exports.up = (pgm) => {
  pgm.createTable('todos', {
    id: 'id',
    title: { type: 'varchar(255)', notNull: true },
    completed: { type: 'boolean', notNull: true, default: false },
    created_at: { type: 'timestamp', notNull: true, default: pgm.func('current_timestamp') },
  });
};

exports.down = (pgm) => {
  pgm.dropTable('todos');
};
