importimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimportimportimportimportimportimporimimportimporemModel(id: 'post_1', title: 'Saved post', type: BookmarkType.post)), child: const Text('Save post')),
                FilledButton(onPressed: () => _controller.save(const BookmarkItemModel(id: 'reel_1', title: 'Saved reel', type: BookmarkType.reel)), child: const Text('Save reel')),
                FilledButton(onPressed: () => _controller.save(const BookmarkItemModel(id: 'product_1', title: 'Saved product', type: BookmarkType.product)), child: const Text('Save product')),
              ],
            ),
            const SizedBox(height: 8),
            ..._controller.items.map((item) => Card(
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.type.name),
                    trailing: IconButton(onPressed: () => _controller.remove(item.id), icon: const Icon(Icons.delete_outline)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
