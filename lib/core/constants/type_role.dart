enum TypeRole {
  ADMIN,
  USER,
  MANAGER;

  String get label => switch (this) {
    TypeRole.ADMIN => 'Administrador',
    TypeRole.USER => 'Funcionário',
    TypeRole.MANAGER => 'Gerente',
  };
}