# Agent Instructions

## Keep it simple

We're in pre-alpha. Don't overengineer, don't overdocument, don't put too much emphasis on UX. We want to prove the basics first.

## Usage Expectations

This gem can only be used with Rails applications for now. In theory we can support any Ruby codebase using zeitwerk, but that's not a priority at this point.

## Testing

Never test private methods. If it seems that we should test a private method, the method should probably be public on a different class.
