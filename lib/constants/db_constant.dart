class TableNames {
  static const transaction = 'transaction';
  static const category = 'category';
  static const account = 'account';
}

class TransactionFields {
  static const id = 'id';
  static const userId = 'user_id';
  static const categoryId = 'category_id';
  static const accountId = 'account_id';
  static const amount = 'amount';
  static const type = 'type';
  static const note = 'note';
  static const date = 'date';
  static const attachments = 'attachments';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const isDeleted = 'is_deleted';
  static const isSynced = 'is_synced';
}

class CategoryFields {
  static const id = 'id';
  static const name = 'name';
  static const type = 'type';
  static const icon = 'icon';
  static const color = 'color';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const isDeleted = 'is_deleted';
  static const isSynced = 'is_synced';
}

class AccountFields {
  static const id = 'id';
  static const name = 'name';
  static const balance = 'balance';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const isDeleted = 'is_deleted';
  static const isSynced = 'is_synced';
}
