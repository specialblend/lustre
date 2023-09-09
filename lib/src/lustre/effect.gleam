// IMPORTS ---------------------------------------------------------------------

import gleam/list

// TYPES -----------------------------------------------------------------------

/// A `Effect` represents some side effect we want the Lustre runtime to perform.
/// It is parameterised by our app's `action` type because some effects need to
/// get information back into your program.
///
pub opaque type Effect(msg) {
  Effect(List(fn(fn(msg) -> Nil) -> Nil))
}

// CONSTRUCTORS ----------------------------------------------------------------

/// Create a `Effect` from some custom side effect. This is mostly useful for 
/// package authors, or for integrating other libraries into your Lustre app.
///
/// We pass in a function that recieves a `dispatch` callback that can be used
/// to send messages to the Lustre runtime. We could, for example, create a `tick`
/// command that uses the `setTimeout` JavaScript API to send a message to the
/// runtime every second:
///
/// ```gleam
/// import lustre/effect.{Effect}
/// 
/// external fn set_interval(callback: fn() -> any, interval: Int) =
///   "" "window.setInterval"
/// 
/// pub fn every_second(msg: msg) -> Effect(msg) {
///   use dispatch <- effect.from
/// 
///   set_interval(fn() { dispatch(msg) }, 1000)
/// }
/// ```
///
pub fn from(effect: fn(fn(msg) -> Nil) -> Nil) -> Effect(msg) {
  Effect([effect])
}

/// Typically our app's `update` function needs to return a tuple of
/// `#(model, Effect(msg))`. When we don't need to perform any side effects we
/// can just return `none()`!
///
pub fn none() -> Effect(msg) {
  Effect([])
}

// MANIPULATIONS ---------------------------------------------------------------

/// 
///
pub fn batch(effects: List(Effect(msg))) -> Effect(msg) {
  Effect({
    use b, Effect(a) <- list.fold(effects, [])
    list.append(b, a)
  })
}

pub fn map(effect: Effect(a), f: fn(a) -> b) -> Effect(b) {
  let Effect(l) = effect
  Effect(list.map(
    l,
    fn(effect) { fn(dispatch) { effect(fn(a) { dispatch(f(a)) }) } },
  ))
}
