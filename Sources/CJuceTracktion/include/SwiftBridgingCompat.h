// -*- C++ -*-
//===----------------------------------------------------------------------===//
// Swift C++ Interop Compatibility Header
//
// This provides Swift C++ interoperability macros. When compiled with a Swift-aware
// compiler, these expand to proper attributes. Otherwise, they're no-ops.
//===----------------------------------------------------------------------===//
#ifndef SWIFT_BRIDGING_COMPAT_H
#define SWIFT_BRIDGING_COMPAT_H

#ifdef __has_attribute
#define _CXX_INTEROP_HAS_ATTRIBUTE(x) __has_attribute(x)
#else
#define _CXX_INTEROP_HAS_ATTRIBUTE(x) 0
#endif

#if _CXX_INTEROP_HAS_ATTRIBUTE(swift_attr)

#define SWIFT_SELF_CONTAINED __attribute__((swift_attr("import_owned")))

#define SWIFT_RETURNS_INDEPENDENT_VALUE __attribute__((swift_attr("import_unsafe")))

#define _CXX_INTEROP_STRINGIFY(_x) #_x

#define SWIFT_SHARED_REFERENCE(_retain, _release)                                \
  __attribute__((swift_attr("import_reference")))                          \
  __attribute__((swift_attr(_CXX_INTEROP_STRINGIFY(retain:_retain))))      \
  __attribute__((swift_attr(_CXX_INTEROP_STRINGIFY(release:_release))))

#define SWIFT_IMMORTAL_REFERENCE                                                \
  __attribute__((swift_attr("import_reference")))                         \
  __attribute__((swift_attr(_CXX_INTEROP_STRINGIFY(retain:immortal))))    \
  __attribute__((swift_attr(_CXX_INTEROP_STRINGIFY(release:immortal))))

#define SWIFT_UNSAFE_REFERENCE                                                  \
  __attribute__((swift_attr("import_reference")))                         \
  __attribute__((swift_attr(_CXX_INTEROP_STRINGIFY(retain:immortal))))    \
  __attribute__((swift_attr(_CXX_INTEROP_STRINGIFY(release:immortal))))   \
  __attribute__((swift_attr("unsafe")))

#define SWIFT_NAME(_name) __attribute__((swift_name(#_name)))

#define SWIFT_COMPUTED_PROPERTY \
  __attribute__((swift_attr("import_computed_property")))

#define SWIFT_MUTATING \
  __attribute__((swift_attr("mutating")))

#define SWIFT_UNCHECKED_SENDABLE \
  __attribute__((swift_attr("@Sendable")))

#define SWIFT_NONCOPYABLE \
  __attribute__((swift_attr("~Copyable")))

#define SWIFT_NONESCAPABLE \
  __attribute__((swift_attr("~Escapable")))

#define SWIFT_ESCAPABLE \
  __attribute__((swift_attr("Escapable")))

#define SWIFT_RETURNS_RETAINED __attribute__((swift_attr("returns_retained")))

#define SWIFT_RETURNS_UNRETAINED \
  __attribute__((swift_attr("returns_unretained")))

#else  // #if _CXX_INTEROP_HAS_ATTRIBUTE(swift_attr)

// Empty defines for compilers that don't support `attribute(swift_attr)`.
#define SWIFT_SELF_CONTAINED
#define SWIFT_RETURNS_INDEPENDENT_VALUE
#define SWIFT_SHARED_REFERENCE(_retain, _release)
#define SWIFT_IMMORTAL_REFERENCE
#define SWIFT_UNSAFE_REFERENCE
#define SWIFT_NAME(_name)
#define SWIFT_COMPUTED_PROPERTY
#define SWIFT_MUTATING
#define SWIFT_UNCHECKED_SENDABLE
#define SWIFT_NONCOPYABLE
#define SWIFT_NONESCAPABLE
#define SWIFT_ESCAPABLE
#define SWIFT_RETURNS_RETAINED
#define SWIFT_RETURNS_UNRETAINED

#endif // #if _CXX_INTEROP_HAS_ATTRIBUTE(swift_attr)

#undef _CXX_INTEROP_HAS_ATTRIBUTE

#endif // SWIFT_BRIDGING_COMPAT_H
