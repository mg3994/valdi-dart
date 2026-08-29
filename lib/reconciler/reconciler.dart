import '../framework/framework.dart';

/// Represents a mutation operation produced by the reconciler diffing process.
sealed class MutationOp {
  const MutationOp();
}

/// Insert a new component at the target index under parent.
final class InsertOp extends MutationOp {
  final Component component;
  final int index;
  final String? parentTag;

  const InsertOp({
    required this.component,
    required this.index,
    this.parentTag,
  });

  @override
  String toString() => 'InsertOp(component: $component, index: $index, parentTag: $parentTag)';
}

/// Update an existing component node (e.g. attributes or text value change).
final class UpdateOp extends MutationOp {
  final Component oldComponent;
  final Component newComponent;
  final int index;
  final Map<String, String> attributeChanges;

  const UpdateOp({
    required this.oldComponent,
    required this.newComponent,
    required this.index,
    this.attributeChanges = const {},
  });

  @override
  String toString() =>
      'UpdateOp(index: $index, attrs: $attributeChanges, new: $newComponent)';
}

/// Delete a component at index.
final class DeleteOp extends MutationOp {
  final Component component;
  final int index;

  const DeleteOp({
    required this.component,
    required this.index,
  });

  @override
  String toString() => 'DeleteOp(component: $component, index: $index)';
}

/// Move a component from oldIndex to newIndex.
final class MoveOp extends MutationOp {
  final Component component;
  final int oldIndex;
  final int newIndex;

  const MoveOp({
    required this.component,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  String toString() => 'MoveOp(from: $oldIndex, to: $newIndex)';
}

/// Reconciler engine that performs diffing between component trees
/// and generates minimal mutation operations.
class Reconciler {
  /// Diff two component trees (old and new) and generate list of [MutationOp].
  List<MutationOp> diff(Component? oldTree, Component? newTree, {String? parentTag}) {
    final ops = <MutationOp>[];

    if (oldTree == null && newTree == null) {
      return ops;
    }

    if (oldTree == null && newTree != null) {
      ops.add(InsertOp(component: newTree, index: 0, parentTag: parentTag));
      return ops;
    }

    if (oldTree != null && newTree == null) {
      ops.add(DeleteOp(component: oldTree, index: 0));
      return ops;
    }

    final oldNode = oldTree!;
    final newNode = newTree!;

    // If identical or equal according to Component == operator, no mutation needed.
    if (oldNode == newNode) {
      return ops;
    }

    // Check component types using Dart 3 pattern matching
    switch ((oldNode, newNode)) {
      case (Text oldT, Text newT):
        if (oldT.value != newT.value || oldT.escape != newT.escape) {
          ops.add(UpdateOp(oldComponent: oldT, newComponent: newT, index: 0));
        }
      case (DomComponent oldD, DomComponent newD):
        if (oldD.tag != newD.tag) {
          // Different tags: Replace
          ops.add(DeleteOp(component: oldD, index: 0));
          ops.add(InsertOp(component: newD, index: 0, parentTag: parentTag));
        } else {
          // Same tag: diff attributes and children
          final attrChanges = _diffAttributes(oldD.attributes, newD.attributes);
          if (attrChanges.isNotEmpty) {
            ops.add(UpdateOp(
              oldComponent: oldD,
              newComponent: newD,
              index: 0,
              attributeChanges: attrChanges,
            ));
          }
          final childOps = diffChildren(
            oldD.children.toList(),
            newD.children.toList(),
            parentTag: newD.tag,
          );
          ops.addAll(childOps);
        }
      case (Fragment oldF, Fragment newF):
        final childOps = diffChildren(
          oldF.children.toList(),
          newF.children.toList(),
          parentTag: parentTag,
        );
        ops.addAll(childOps);
      default:
        // Different component types: replace node
        if (oldNode.runtimeType != newNode.runtimeType) {
          ops.add(DeleteOp(component: oldNode, index: 0));
          ops.add(InsertOp(component: newNode, index: 0, parentTag: parentTag));
        } else {
          // Build custom composite components
          final oldBuilt = _expandComponent(oldNode);
          final newBuilt = _expandComponent(newNode);
          return diff(oldBuilt, newBuilt, parentTag: parentTag);
        }
    }

    return ops;
  }

  /// Diff lists of child components, handling Insert, Delete, Update, Move.
  List<MutationOp> diffChildren(
    List<Component> oldChildren,
    List<Component> newChildren, {
    String? parentTag,
  }) {
    final ops = <MutationOp>[];

    final oldLen = oldChildren.length;
    final newLen = newChildren.length;
    final maxLen = oldLen > newLen ? oldLen : newLen;

    for (var i = 0; i < maxLen; i++) {
      if (i >= oldLen) {
        // New child added
        ops.add(InsertOp(component: newChildren[i], index: i, parentTag: parentTag));
      } else if (i >= newLen) {
        // Old child removed
        ops.add(DeleteOp(component: oldChildren[i], index: i));
      } else {
        final oldChild = oldChildren[i];
        final newChild = newChildren[i];

        if (oldChild != newChild) {
          // Check if child moved from elsewhere
          final movedIndex = _findMatchingIndex(newChild, oldChildren, skipIndex: i);
          if (movedIndex != -1) {
            ops.add(MoveOp(component: newChild, oldIndex: movedIndex, newIndex: i));
          } else {
            ops.addAll(diff(oldChild, newChild, parentTag: parentTag));
          }
        }
      }
    }

    return ops;
  }

  int _findMatchingIndex(Component target, List<Component> list, {required int skipIndex}) {
    for (var i = 0; i < list.length; i++) {
      if (i != skipIndex && list[i] == target) {
        return i;
      }
    }
    return -1;
  }

  Map<String, String> _diffAttributes(Map<String, String> oldAttrs, Map<String, String> newAttrs) {
    final changes = <String, String>{};
    for (final entry in newAttrs.entries) {
      if (oldAttrs[entry.key] != entry.value) {
        changes[entry.key] = entry.value;
      }
    }
    for (final key in oldAttrs.keys) {
      if (!newAttrs.containsKey(key)) {
        changes[key] = ''; // Removed attribute marked as empty
      }
    }
    return changes;
  }

  Component? _expandComponent(Component comp) {
    final children = comp.build().toList();
    if (children.isEmpty) return null;
    if (children.length == 1) return children.first;
    return Fragment(children);
  }
}
