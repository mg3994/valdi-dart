import '../framework/framework.dart';

/// Abstract Native View node representing native view instances (e.g. Android View / iOS UIView / Canvas / Skia / Impeller node).
class NativeViewNode {
  final String id;
  final String type;
  Map<String, String> attributes;
  final List<NativeViewNode> children;

  NativeViewNode({
    required this.id,
    required this.type,
    Map<String, String>? attributes,
    List<NativeViewNode>? children,
  })  : attributes = attributes ?? {},
        children = children ?? [];

  @override
  String toString() => 'NativeViewNode($id, type: $type, attrs: $attributes, childrenCount: ${children.length})';
}

/// Abstract interface driving platform native rendering (Android, iOS, Flutter/Impeller, Web).
abstract class NativeRenderDriver {
  /// Mounts an initial component tree into a native view root node.
  NativeViewNode mount(Component rootComponent);

  /// Applies a list of reconciler diff mutations directly to the native view hierarchy.
  void applyMutations(NativeViewNode rootNativeNode, List<RenderMutation> mutations);
}

/// A lightweight cross-platform Native Render Driver that translates Valdi components into platform view nodes.
class DefaultNativeRenderDriver implements NativeRenderDriver {
  int _nodeIdCounter = 0;

  @override
  NativeViewNode mount(Component rootComponent) {
    return _createNativeNode(rootComponent);
  }

  NativeViewNode _createNativeNode(Component component) {
    final id = 'native_view_${++_nodeIdCounter}';

    if (component is Text) {
      return NativeViewNode(
        id: id,
        type: 'NativeTextView',
        attributes: {
          'text': component.value,
          'escape': '${component.escape}',
        },
      );
    } else if (component is DomComponent) {
      final childrenNodes = component.children.map(_createNativeNode).toList();
      return NativeViewNode(
        id: id,
        type: _mapTagToNativePlatformView(component.tag),
        attributes: Map.of(component.attributes),
        children: childrenNodes,
      );
    } else if (component is Fragment) {
      final childrenNodes = component.children.map(_createNativeNode).toList();
      return NativeViewNode(
        id: id,
        type: 'NativeViewGroup',
        children: childrenNodes,
      );
    } else {
      final built = component.build();
      if (built.isNotEmpty) {
        return _createNativeNode(built.first);
      }
      return NativeViewNode(id: id, type: 'NativeEmptyView');
    }
  }

  String _mapTagToNativePlatformView(String tag) {
    switch (tag) {
      case 'vstack':
        return 'AndroidLinearLayoutVertical / UIStackViewVertical';
      case 'hstack':
        return 'AndroidLinearLayoutHorizontal / UIStackViewHorizontal';
      case 'img':
        return 'AndroidImageView / UIImageView';
      case 'button':
        return 'AndroidButton / UIButton';
      case 'scrollview':
        return 'AndroidScrollView / UIScrollView';
      default:
        return 'AndroidViewGroup / UIView ($tag)';
    }
  }

  @override
  void applyMutations(NativeViewNode rootNativeNode, List<RenderMutation> mutations) {
    // Collect and sort deletions descending by index to avoid index shifting bugs during removal.
    final deletions = mutations.whereType<DeleteMutation>().toList()
      ..sort((a, b) => b.path.last.compareTo(a.path.last));

    final nonDeletions = mutations.where((m) => m is! DeleteMutation);

    for (final mutation in nonDeletions) {
      switch (mutation) {
        case InsertMutation insert:
          final parentNode = _findNodeByPath(rootNativeNode, insert.path.sublist(0, insert.path.length - 1));
          final index = insert.path.last;
          final newNode = _createNativeNode(insert.component);
          if (parentNode != null) {
            if (index <= parentNode.children.length) {
              parentNode.children.insert(index, newNode);
            } else {
              parentNode.children.add(newNode);
            }
          }

        case UpdateMutation update:
          final targetNode = _findNodeByPath(rootNativeNode, update.path);
          if (targetNode != null) {
            if (update.attributeChanges != null) {
              for (final entry in update.attributeChanges!.entries) {
                if (entry.value.isEmpty) {
                  targetNode.attributes.remove(entry.key);
                } else {
                  targetNode.attributes[entry.key] = entry.value;
                }
              }
            }
            if (update.newComponent is Text) {
              targetNode.attributes['text'] = (update.newComponent as Text).value;
            }
          }

        case MoveMutation move:
          final fromParent = _findNodeByPath(rootNativeNode, move.fromPath.sublist(0, move.fromPath.length - 1));
          final toParent = _findNodeByPath(rootNativeNode, move.toPath.sublist(0, move.toPath.length - 1));
          if (fromParent != null && toParent != null && move.fromPath.last < fromParent.children.length) {
            final movedNode = fromParent.children.removeAt(move.fromPath.last);
            toParent.children.insert(move.toPath.last, movedNode);
          }
        default:
          break;
      }
    }

    // Apply sorted deletions descending
    for (final delete in deletions) {
      final parentNode = _findNodeByPath(rootNativeNode, delete.path.sublist(0, delete.path.length - 1));
      final index = delete.path.last;
      if (parentNode != null && index < parentNode.children.length) {
        parentNode.children.removeAt(index);
      }
    }
  }

  NativeViewNode? _findNodeByPath(NativeViewNode root, List<int> path) {
    var current = root;
    for (final index in path) {
      if (index >= current.children.length) {
        return null;
      }
      current = current.children[index];
    }
    return current;
  }
}
