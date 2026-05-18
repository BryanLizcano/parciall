// Envoltura de paginación genérica para HU-13, HU-17, HU-19.

class PagedResult<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  const PagedResult({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  bool get hasNextPage => currentPage < totalPages - 1;
  bool get isFirstPage => currentPage == 0;
}
