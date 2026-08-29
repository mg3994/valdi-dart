import '../framework/framework.dart';

/// The Reconciler diffs two [Component] trees (old vs new) and outputs a list of [RenderMutation]s.
class Reconciler {
  const Reconciler();

  /// Compares [oldTree] and [newTree], producing a list of mutations required to transform [oldTree] into [newTree].
  List<RenderMutation> diff(Component? oldTree, Component? newTree, [List<int> currentPath = const []]) {
    final mutations = <RenderMutation>[];

    if (oldTree == null && newTree == null) {
      return mutations;
    }

    if (oldTree == null && newTree != null) {
      mutations.add(InsertMutation(currentPath, newTree));
      return mutations;
    }

    if (oldTree != null && newTree == null) {
      mutations.add(DeleteMutation(currentPath, oldTree));
      return mutations;
    }

    // Both oldTree and newTree are non-null here.
    final oldComponent = oldTree!;
    final newComponent = newTree!;

    // If identical or structurally equal, no mutations needed.
    if (oldComponent == newComponent) {
      return mutations;
    }

    // Handle different node types.
    switch ((oldComponent, newComponent)) {
      // 1. Both are Text nodes
      case (Text oldText, Text newText):
        if (oldText.value != newText.value || oldText.escape != newText.escape) {
          mutations.add(UpdateMutation(
            path: currentPath,
            oldComponent: oldText,
            newComponent: newText,
          ));
        }

      // 2. Both are DomComponent / Element nodes with matching tag
      case (DomComponent oldDom, DomComponent newDom) when oldDom.tag == newDom.tag:
        final attrChanges = _diffAttributes(oldDom.attributes, newDom.attributes);
        if (attrChanges.isNotEmpty) {
          mutations.add(UpdateMutation(
            path: currentPath,
            oldComponent: oldDom,
            newComponent: newDom,
            attributeChanges: attrChanges,
          ));
        }
        // Diff children
        final childMutations = _diffChildren(
          oldDom.children.toList(),
          newDom.children.toList(),
          currentPath,
        );
        mutations.addAll(childMutations);

      // 3. Both are Fragments
      case (Fragment oldFrag, Fragment newFrag):
        final childMutations = _diffChildren(
          oldFrag.children.toList(),
          newFrag.children.toList(),
          currentPath,
        );
        mutations.addAll(childMutations);

      // 4. Mismatched component types or tags -> replace node completely (Update or Delete+Insert)
      default:
        mutations.add(UpdateMutation(
          path: currentPath,
          oldComponent: oldComponent,
          newComponent: newComponent,
        ));
    }

    return mutations;
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
        changes[key] = ''; // empty string represents removed attribute
      }
    }
    return changes;
  }

  List<RenderMutation> _diffChildren(
    List<Component> oldChildren,
    List<Component> newChildren,
    List<int> parentPath,
  ) {
    final mutations = <RenderMutation>[];
    final oldLen = oldChildren.length;
    final newLen = newChildren.length;
    final maxLen = oldLen > newLen ? oldLen : newLen;

    for (var i = 0; i < maxLen; i++) {
      final childPath = [...parentPath, i];
      if (i < oldLen && i < newLen) {
        mutations.addAll(diff(oldChildren[i], newChildren[i], childPath));
      } else if (i >= oldLen) {
        mutations.add(InsertMutation(childPath, newChildren[i]));
      } else if (i >= newLen) {
        mutations.add(DeleteMutation(childPath, oldChildren[i]));
      }
    }

    return mutations;
  }
}
