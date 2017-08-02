## ATP Earnings Data

This is a project that fetches the combined prize money (singles and doubles) for each player currently ranked in the ATP.

The output of the script is a `csv` file in the `data` folder. It uses Ruby and creates batches of threads for better efficiency.

## Why?

As a tennis player and fan, I belive this data shows how brutal the professional circuit is. This is more evidence that we need
a better support system for players that are not in the million dollar earnings range, since many of them have to immediately
return to the workforce right after playing professionally.

Maybe the solution is to distribute the prizes more. Or have more lower level tournaments that pay better.

Regardless, my goal here was to create a conversation about this issue. Tennis is life.

## Tech details

To run:

```
  $ gem install bundler
  $ bundle install
  $ ruby lib/main.rb
```
If you try to run this, be aware that I automated pushing the newest file to Github, so that part may fail for you,
but the csv file will be created nonetheless.

*Contributing*

Pull requests are welcome! Please create an issue first so we can discuss. PRs without corresponding issues will be closed.
