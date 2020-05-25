        return Column(
          children: [
            if(i == data.documents.length) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "${when.day} ${months[when.month-1]} ${when.year}",
                  style: Theme.of(context).textTheme.subhead
                ),
              )
            else if(
              !areSameDay(
                data.documents[i+1].data["when"],
                data.documents[i].data["when"]
              )
            )
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "${when.day} ${months[when.month-1]} ${when.year}",
                  style: Theme.of(context).textTheme.subhead
                ),
              ),
