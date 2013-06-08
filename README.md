# thread n' trigger

## the trigger

The atom of our system, the trigger is any actionable outline item, like a task.

Sometimes you really need to do something, but before you get to it there's all these steps you must complete to clear up the field and unblock the all important task. Triggers handle this scenario rather elegantly. Suppose you have:
  clear up my desk
    buy woodworking supplies
      start woodworking project on my desk

Starting the woodworking project is your goal. But the next action to complete is to clear up your desk, and that's what's gonna appear on your list. However, keeping the goal in mind might be important in motivating and reminding you why you need to clear up your desk next. Otherwise you could easily forget and procrastinate on clearing your desk since it's such a menial chore. To remedy this, you can add an important marker to the goal, like so `!start woodworking project on my desk`. Now, when the `clear up my desk` task is folded, that's what it's gonna show:
  clear up my desk --> start woodworking project on my desk

What tnt did for you was to scan down your trigger chain looking for an important item, and pull the first such item up to remind you of what's important.

Now, how do triggers handle subtasks? Let's see, we would have to place the subtask first with the parent task/project as it's child. That looks even uglier than it sounds. And how do you even handle multiple subtasks? What we really need is our second and last basic concept..

## the thread

Threads are tnt's basic concept of grouping (sorry, they're also it's only concept of grouping). Without them we'd all be serial-triggering ourselves into the abyss of single threadness. Wait, what? That last sentence for all it's metaphor actually holds a very important realization (it surprised me too). A "thread" is exactly the opposite of what the noun hints at. If you string together several triggers in serial fashion, nesting one after the other, you get a singleminded thread, whereas using a Thread allows you concurrent, parallel threads. You can think of tnt's thread as a verb, a construct which allows you to "thread" your work into simultaneous undertakings. Like a project having several subtasks.

A thread's base syntax is a lone double-quote. You could have `"my birthday party` on your outline and that'd be a thread anywhere it appears. Note the double-quote comes before everything else and is unattended by a closing quote. Closing the quote would be a mistake and tnt's syntax calls for not considering the resulting imaginary line a thread. Imaginary because you'll never make that mistake, I'm sure you won't. If you do you will scratch your head at tnt's lousy syntax parsing and wonder why this author has written such crappy software to go with his need to invent a system to massage his ego. There's a reason for the rule, however, and that is to allow for normal quoted text in your outline. But you can have quoted text inside the thread's text, as in `" build a "cannon" out of "gold"`, as long as all other double-quotes come in pairs. Notice too that it doesn't matter whether the text follows glued to the starting double-quote or you have a space/tab after it.

The most obvious use case for threads is to start out your outline with them. The start of an outline that purports to organize your life could have the big picture, for instance your areas of responsibility (I borrow from GTD freely.) That's how most life outlines work, they start with the big picture and go drilling down, down. I don't want to spin your head right 'round, but let me just say tnt gives all these outlines the finger by allowing you to start with the big picture and then BAM! Next you're already as down as Marvin the Paranoid Android.
