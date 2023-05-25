// MIT License
//
// Copyright (c) 2021 Point-Free, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

extension View {
  /// Synchronizes model state to view state via two-way bindings.
  ///
  /// SwiftUI comes with many property wrappers that can be used in views to drive view state, like
  /// field focus. Unfortunately, these property wrappers _must_ be used in views. It's not possible
  /// to extract this logic to an observable object and integrate it with the rest of the model's
  /// business logic, and be in a better position to test this state.
  ///
  /// We can work around these limitations by introducing a published field to your observable
  /// object and synchronizing it to view state with this view modifier.
  ///
  /// - Parameters:
  ///   - modelValue: A binding from model state. _E.g._, a binding derived from a published field
  ///     on an observable object.
  ///   - viewValue: A binding from view state. _E.g._, a focus binding.
  @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
  public func bind<ModelValue: _Bindable, ViewValue: _Bindable>(
    _ modelValue: ModelValue, to viewValue: ViewValue
  ) -> some View
  where ModelValue.Value == ViewValue.Value, ModelValue.Value: Equatable {
    self.modifier(_Bind(modelValue: modelValue, viewValue: viewValue))
  }
}

@available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
private struct _Bind<ModelValue: _Bindable, ViewValue: _Bindable>: ViewModifier
where ModelValue.Value == ViewValue.Value, ModelValue.Value: Equatable {
  let modelValue: ModelValue
  let viewValue: ViewValue

  @State var hasAppeared = false

  func body(content: Content) -> some View {
    content
      .onAppear {
        guard !self.hasAppeared else { return }
        self.hasAppeared = true
        guard self.viewValue.wrappedValue != self.modelValue.wrappedValue else { return }
        self.viewValue.wrappedValue = self.modelValue.wrappedValue
      }
      .onChange(of: self.modelValue.wrappedValue) {
        guard self.viewValue.wrappedValue != $0
        else { return }
        self.viewValue.wrappedValue = $0
      }
      .onChange(of: self.viewValue.wrappedValue) {
        guard self.modelValue.wrappedValue != $0
        else { return }
        self.modelValue.wrappedValue = $0
      }
  }
}

public protocol _Bindable {
  associatedtype Value
  var wrappedValue: Value { get nonmutating set }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension AccessibilityFocusState: _Bindable {}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension AccessibilityFocusState.Binding: _Bindable {}

@available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
extension AppStorage: _Bindable {}

extension Binding: _Bindable {}

@available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
extension FocusedBinding: _Bindable {}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension FocusState: _Bindable {}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension FocusState.Binding: _Bindable {}

@available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
extension SceneStorage: _Bindable {}

extension State: _Bindable {}
