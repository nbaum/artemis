class ErrorsController < ApplicationController
  
  PITH = [
    "But over all things brooding slept\nThe quiet sense of something lost.",
    "For 'tis a truth well known to most,\nThat whatsoever thing is lost,\nWe seek it, ere it comes to light,\nIn every cranny but the right.",
    "Like the dew on the mountain,\nLike the foam on the river,\nLike the bubble on the fountain,\nThou art gone, and forever!",
    "Wise men ne'er sit and wail their loss,\nBut cheerly seek how to redress their harms.",
  ]
  
  define_method "404" do
    @pith = PITH.sample
  end
  
end
