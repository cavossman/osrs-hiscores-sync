const users = [
    'v bros',
    'me gonna die',
    'Temp BTW',
    'MitchyBee',
    'also spud',
    'BabasFatNuts',
    'IsaacNewton',
    'soft bros',
    'taynur',
    'gus is maxed'
];

/* global fetch */
exports.handler = async () => {
    await Promise.allSettled(users.reduce((promises, user) => {
        const sanitizedUser = user.replaceAll(' ', '+');

        promises.push(
            timeout(5_000, fetch(`https://crystalmathlabs.com/tracker/update.php?player=${sanitizedUser}`, { mode: "no-cors" })), 
            timeout(5_000, fetch(`https://templeosrs.com/php/add_datapoint.php?player=${sanitizedUser}`, { mode: "no-cors" }))
        )
        
        return promises;
    }, []))
        .then(responses => {
            // log pass/fail
            responses.forEach(response => {
                if (response.reason) {
                    console.log('Failed')
                } else {
                    console.log('Finished')
                }
            });
        })
        .catch(err => {
            return {
                'code': 500,
                'body': err.message
            }
        })


    return {
        'code': 200,
        'body': 'Finished'
    }
}

const timeout = (ms, promise) => {
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        reject(new Error('TIMEOUT'))
      }, ms)
  
      promise
        .then(value => {
          clearTimeout(timer)
          resolve(value)
        })
        .catch(reason => {
          clearTimeout(timer)
          reject(reason)
        })
    })
}